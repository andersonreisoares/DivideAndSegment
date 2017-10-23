# The divide and segment method

This code tackle the problem of creating tiles for parallel segmentation. After defining tiles, any algorithm can run on them in an independent way, since the
implementation is based on multiprogrammed techniques. The code define noncrisp borders between tiles, so it's not necessary a postprocessing of neighboring regions.

## Authors
Anderson Soares, Thales Körting, Emiliano Castejon and Leila Fonseca
Image Processing Division, National Institute of Space Research, INPE, São José dos Campos, Brazil

## Example

```
divSeg('input.tif',8,2,20,10,100)
```

img              - input image
filterOption     - 1 for standard magnitude approach, 2 for directional approach (recommended)
line_number      - Nummber of lines to split the image (4 - divide in 16 tiles)
vchunk           - Vertical chunk size
hchunk           - horizontal chuck size
max_displacement - maximum displacement to the crop line

## Warning

The current version do not handle geographic information. This function will soon be implemented.


## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Related papers
Divide And Segment - An Alternative For Parallel Segmentation. TS Korting, EF Castejon, LMG Fonseca - GeoInfo, 97-104 [PDF](http://www.geoinfo.info/proceedings_geoinfo2011.split/proceedings_geoinfo2011.104-111.pdf)

Improvements of the divide and segment method for parallel image segmentation. AR Soares, TS Körting, LMG Fonseca - Revista Brasileira de Cartografia 68 (6) [PDF](http://www.lsie.unb.br/rbc/index.php/rbc/article/viewFile/1602/996)
