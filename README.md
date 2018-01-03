# ADCP_bottom_detection
An algorithm that detects the bottom in ADCP backscatter data as part of a Matlab package for ADCP processing

This work-in-progress algorithm is an ad-on to a set of Matlab functions used to process ADCP data as provided by the Geomar. The function detects the bottom fro a given ADCP backscatter profile using the gradient of the backscatter and a Gaussian mixcture model. It is set to have more false negatives than false psoitives in thye moment. The algorithm can get confused when the bottom is very close to the ADCP, I worked around this by calculating the fft of the backscatter in the upper 30 bins, FFTs with much engery at higher frequencies indicate the presence of the sea floor, whereas FFTs with energy at low frequencies indicate open ocean backscatter conditions. 

 ![](bottom_detection_00065.tiff)
