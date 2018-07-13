#!/usr/bin/python2

# Python3 compatibility
from __future__ import division, print_function, absolute_import
import warnings
warnings.simplefilter(action='ignore', category=FutureWarning)

import os
import fnmatch
from PIL import Image
import xml.etree.ElementTree as ET
import pandas as pd
import tensorflow as tf

tf.logging.set_verbosity(tf.logging.INFO)

flags = tf.app.flags
flags.DEFINE_string('in_img_dir','','Image input directory')
flags.DEFINE_string('img_ext','','Image file extension')
flags.DEFINE_string('in_xml_dir','','Annotation input directory')
flags.DEFINE_string('out_img_dir','','Image output directory')
flags.DEFINE_string('out_csv','','Annotation output file')
FLAGS = flags.FLAGS

# size = [width, height]
IMG_SIZE = [960, 540]

def searchExtension(root_dir, extension):
   matches = []
   for root, dirnames, filenames in os.walk(root_dir):
      for filename in fnmatch.filter(filenames, '*.' + extension):
         matches.append(os.path.join(root, filename))
   return matches

def resizeImages(input_dir, output_dir, new_size, ext):

   images = searchExtension(input_dir, ext)

   if ext.upper() == 'JPG':
      img_format = 'JPEG'
   else:
      img_format = ext

   # Resize images and save output
   for image_path in images:
      image = Image.open(image_path)
      image = image.resize(size=new_size, resample=Image.BICUBIC)
      full_path, image_name = os.path.split(image_path)
      image_name = os.path.splitext(image_name)[0]
      rest, parent = os.path.split(full_path)
      output_path = os.path.join(output_dir, parent, image_name)
      output_path += '.' + ext
      # Create output directory, if not present
      if not os.path.exists(os.path.dirname(output_path)):
         os.makedirs(os.path.dirname(output_path))
      image.save(output_path, format=img_format)

def includeAnnotation(xmin, xmax, ymin, ymax, new_size):
   return xmax < new_size[0] * 1.25 \
      and ymax < new_size[1] * 1.25 \
      and xmin > - new_size[0] * 0.25 \
      and ymin > - new_size[1] * 0.25

def createAnnotation(input_dir, output, new_size):

   xml_files = searchExtension(input_dir, 'xml')
   data = []
   for xml_file in xml_files:
      tree = ET.parse(xml_file)
      root = tree.getroot()
      for member in root.findall('object'):
         original_width = int(root.find('size')[0].text)
         original_height = int(root.find('size')[1].text)
         ratio_width = new_size[0] / original_width
         ratio_height = new_size[1] / original_height
         xmin = int(member[4][0].text) * ratio_width
         ymin = int(member[4][1].text) * ratio_height
         xmax = int(member[4][2].text) * ratio_width
         ymax = int(member[4][3].text) * ratio_height

         if includeAnnotation(xmin, xmax, ymin, ymax, new_size):
            value = (
               root.find('filename').text.replace('png','jpg'),
               int(root.find('size')[0].text) * ratio_width,
               int(root.find('size')[1].text) * ratio_height,
               member[0].text,
               xmin,
               ymin,
               xmax,
               ymax)
            data.append(value)

   column_name = ['filename', 'width', 'height',
      'class', 'xmin', 'ymin', 'xmax', 'ymax']
   xml_df = pd.DataFrame(data, columns=column_name)
   xml_df.to_csv(output, index=None)

def main(argv):

   in_img_dir = FLAGS.in_img_dir
   in_xml_dir = FLAGS.in_xml_dir
   out_img_dir = FLAGS.out_img_dir
   out_csv = FLAGS.out_csv
   img_ext = FLAGS.img_ext
   
   resizeImages(in_img_dir, out_img_dir, IMG_SIZE, img_ext)
   print('Successfully resized images: ' + out_img_dir)
   createAnnotation(in_xml_dir, out_csv, IMG_SIZE)
   print('Successfully generated CSV annotations: ' + out_csv)

if __name__ == '__main__':
   tf.app.run()

