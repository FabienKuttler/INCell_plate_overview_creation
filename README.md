# INCell_plate_overview_creation
This macros creates plate overviews from images acquired with an INCell Analyzer automated fluorescence microscope. The purpose is to help visualization and navigation at the whole plate level. The wells for which no images have been acquired will appear black. Colors can be chosen, grids and well name can be added. It can be applied to single plates or multiple plates (1 subfolder per plate). The source images are not modified in any way.

![Image](https://github.com/FabienKuttler/INCell_plate_overview_creation/blob/main/Images/goal_of_macro.png)

## Installation
This is a small macro for Fiji. It can be copy/pasted into the plugins folders of the Fiji installation. It is then available in Fiji's Plugins menu.
## Source and destination folder
At start of the macro, a first window appears, allowing the selection of source and destination folders:
![Image](https://github.com/FabienKuttler/INCell_plate_overview_creation/blob/main/Images/SourceAndDestination.png)

## Information from source folder
Information from source folder is then extracted (plate format, fov, size...) and settings for the overviews are suggested accordingly (but can be overridden if desired) 
![Image](https://github.com/FabienKuttler/INCell_plate_overview_creation/blob/main/Images/SourceInfos.png)

## Custom plate format
When selecting the plate format "Custom, from well X to well Y"
![Image](https://github.com/FabienKuttler/INCell_plate_overview_creation/blob/main/Images/partial_plate_overview.png)
## Number of FOV per well and FOV setup
Custom format allows to set the number of rows and columns for FOV layout through the following window.

![Image](https://github.com/FabienKuttler/INCell_plate_overview_creation/blob/main/Images/Custom_FOV_format.png) 
## Z stack Projection method
If Z stacks have been acquired, an additional window allows the selection of projection method to be applied to each stack, between Max Intensity, Sum slices or Gaussian stack focuser.

![Image](https://github.com/FabienKuttler/INCell_plate_overview_creation/blob/main/Images/Z_proj_method.png)
## Settings for color overview generation
The list of channels found in source folders is automatically displayed
![Image](https://github.com/FabienKuttler/INCell_plate_overview_creation/blob/main/Images/OverviewSettings.png)
## Manual setting for Brightness & Contrast
When manual setting is selected, the color windows are displayed to allow manual adjustment for the first plate. The same Min&Max settings are then applied to the following plates if multiple plates in multiple subfolders have been acquired.

![Image](https://github.com/FabienKuttler/INCell_plate_overview_creation/blob/main/Images/manual_setting.png)
In addition to the overviews, a file "Pixel_Size.txt" is also saved in the destination folder. 
It indicates the corrected pixel size of the overviews, to be used in case a scale bar has to be added...
