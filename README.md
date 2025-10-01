<a id="readme-top"></a>


<!-- PROJECT LOGO -->
<br/>
<div align="center">
  <h3 align="center">Visualize TROPOMI NO2 & CH4 Data with a Transparent Background</h3>
  <p align="center">
    <br/>
    Within this project we're going to clip monthly mean Sentinel-5P TROPOMI NO2 data to an area of interest (AOI), visualize the data in a map, and calculate a time series below. On top of that, we're going to create a GIF of our plots.
    <br/>
  </p>
</div>

<div align="center">
  <table>
    <tr>
      <th style="background-color:#f2f2f2;">NO₂</th>
      <th style="background-color:#f2f2f2;">CH₄</th>
    </tr>
    <tr>
      <td style="background-color:#e6f7ff;">
        <img src="https://github.com/reneebichler/visualize_tropomi_data/blob/main/Plots/TROPOMI_NO2_mm_TVC_2019-01-01-2024-12-01_crop_AOI_BO_City_ID_1_animation.gif" width="350">
      </td>
      <td style="background-color:#fff0f0;">
        <img src="https://github.com/reneebichler/visualize-tropomi-data/blob/main/Plots/TROPOMI_CH4_mm_TVC_2019-01-01-2024-12-01_crop_AOI_BO_City_ID_1_animation.gif" width="350">
      </td>
    </tr>
  </table>
</div>


<p align="right">(<a href="#readme-top">back to top</a>)</p>


<!-- Code Structure -->
## Code Structure

The code is structured in 5 codes. The first two numbers indicate the processing order.
A code that starts with "00_" was set up for additional functions or settings.
  
* 00_process_satellite_data.R
* 01_TROPOMI_GEE_download.py
* 02_TROPOMI_create_csv.R
* 03_TROPOMI_time_series.R
* 04_TROPOMI_maps.R

<p align="right">(<a href="#readme-top">back to top</a>)</p>


<!-- CONTACT -->
## Contact

Renée Bichler - rbichler@unc.edu; renee.bichler@uni-a.de

LinkedIn: https://www.linkedin.com/in/ren%C3%A9e-bichler-66782474/

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- SOURCE -->
## Sources

I used data from:

* Sentinel-5P/TROPOMI observations from Copernicus downloaded via Google Earch Enginge

https://developers.google.com/earth-engine/datasets/catalog/COPERNICUS_S5P_OFFL_L3_NO2

https://developers.google.com/earth-engine/datasets/catalog/COPERNICUS_S5P_OFFL_L3_CH4

* Natural Earth data

https://www.naturalearthdata.com/

<p align="right">(<a href="#readme-top">back to top</a>)</p>
