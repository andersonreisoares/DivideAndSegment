# Divide and segment

This code tackle the problem of creating tiles for parallel segmentation. After defining tiles, any algorithm can run on them in an independent way, since the
implementation is based on multiprogrammed techniques. The code define noncrisp borders between tiles, so it's not necessary a postprocessing of neighboring regions.

![Result](https://user-images.githubusercontent.com/9437194/32062553-923b2e12-ba53-11e7-917b-af7c049b8813.jpg)

## Authors
Anderson Soares, Thales Körting, Emiliano Castejon and Leila Fonseca
Image Processing Division, National Institute of Space Research, INPE, São José dos Campos, Brazil

## Parameters

```
divSeg(img,filterOption,line_number,vchunk,hchunk,max_displacement,epsg)
```

img              - input image 

filterOption     - 1 for standard magnitude approach, 2 for directional approach (recommended)

line_number      - Nummber of lines to split the image (4 - divide in 16 tiles)

vchunk           - Vertical chunk size

hchunk           - horizontal chuck size

max_displacement - maximum displacement to the crop line

epsg             - EPSG of image

## Example
```
divSeg('input.tif',8,2,20,10,100,32723)
```


![Result2](https://user-images.githubusercontent.com/9437194/32062558-949526d6-ba53-11e7-9ca1-f5fed93941e6.jpg)


## Warning

For geotiff files, it is necessary to provide the EPSG of image.


## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Related papers
Divide And Segment - An Alternative For Parallel Segmentation. TS Korting, EF Castejon, LMG Fonseca - Lecture Notes in Computer Science 8192:504-515 · May 2013 [PDF](https://www.researchgate.net/publication/265794792_The_Divide_and_Segment_Method_for_Parallel_Image_Segmentation)

Improvements of the divide and segment method for parallel image segmentation. AR Soares, TS Körting, LMG Fonseca - Revista Brasileira de Cartografia 68 (6) [PDF](http://www.lsie.unb.br/rbc/index.php/rbc/article/viewFile/1602/996)
