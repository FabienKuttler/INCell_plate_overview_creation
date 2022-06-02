
//	****************************************************************************************
//	*******														                     *******
//	******* 		Macro for general fluo plate OVERVIEW generation			     *******
//	*******  	Fabien Kuttler, 2022, EPFL-SV-PTECH-PTCB BSF, http://bsf.epfl.ch	 *******
//	*******																		     *******
//	****************************************************************************************

// Get input data and settings***********************************************************************************************
#@ File (label="Image source folder", style="directory", persist=true) imageFolder
#@ File (label="Overviews destination folder", style="directory", persist=true) saveFolder
#@ String (label="Plate format ", choices={"384-well", "96-well", "60-well", "24-well", "12-well", "6-well", "Custom, from well X to well Y"}, style="radioButtonVertical", persist=true) formatPlate
#@ String (label="Number of FOV per well", choices={"1 FOV (1x1)", "4 FOV (2x2)", "9 FOV (3x3)", "16 FOV (4x4)", "25 FOV (5x5)", "21 FOV (circle)", "Custom"}, style="list", persist=true) fovformat
#@ String (label="FOV setup:", choices={"horizontal (standard mode)", "horizontal serpentine mode"}, style="radioButtonVertical", persist=false) fovSetup
#@ Double (label="Image Resizing (pixels)", value=300, persist=true) sizePixel
#@ boolean (label="Cy3/Red", value=false, persist=false) redYes
#@ boolean (label="FITC/Green", value=false, persist=false) greenYes
#@ boolean (label="DAPI/Blue", value=false, persist=false) blueYes
#@ boolean (label="Cy5/FarRed", value=false, persist=false) cy5Yes
#@ boolean (label="TL/BrightField", value=false, persist=false) bfYes
#@ boolean (label="Single Channel", value=false, persist=false) scYes
#@ String (label="Create a final Multicolor Overview?", choices={"Yes", "No"}, style="radioButtonHorizontal", persist=true) colorOverview

// get conditionnal variables************************************************************************************************
requires("1.52p");
if(!File.exists(saveFolder)){File.makeDirectory(saveFolder);}
setBatchMode(true);
var start_h = 0;
var start_i = 1;
run("Colors...", "foreground=white background=black selection=yellow");
letters = newArray("A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P");
numbers = newArray("01","02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24");

// create list of channels to process****************************************************************************************
listOfChannel = newArray(0);
listOfName = newArray(0);
if (redYes)  {listOfChannel = Array.concat(listOfChannel,"Cy3");  listOfName = Array.concat(listOfName," wv Cy3 - Cy3");}
if (greenYes){listOfChannel = Array.concat(listOfChannel,"FITC"); listOfName = Array.concat(listOfName," wv FITC - FITC");}
if (blueYes) {listOfChannel = Array.concat(listOfChannel,"DAPI"); listOfName = Array.concat(listOfName," wv DAPI - DAPI");}
if (cy5Yes)  {listOfChannel = Array.concat(listOfChannel,"Cy5");  listOfName = Array.concat(listOfName," wv Cy5 - Cy5");}
if (bfYes)   {listOfChannel = Array.concat(listOfChannel,"BF");   listOfName = Array.concat(listOfName," wv TL-Brightfield - Cy3");}
if (scYes)   {listOfChannel = Array.concat(listOfChannel,"SC");   listOfName = Array.concat(listOfName,"");}
scMessage = "                     Attention!\nSelect 'Single Channel' when only\na single channel has been acquired with\nmicroscope, whatever the wavelength.\nEither a single channel has been acquired,\nand then you select 'Single Channel' whatever\nthe wavelength used during acquisition,\nor if more than 1 channel have been acquired\nand you want to include in the overview only\none of them, then you select only the desired\nchannel, but not the 'Single Channel' option!";
if (scYes && listOfChannel.length>1){exit(scMessage);}
 
// variables related to format of the plate*********************************************************************************
if(formatPlate=="384-well") {hmax = 16; kmax = 25; cols=24; rows=16; wells=384;}
if(formatPlate=="96-well") 	{hmax = 8; kmax = 13; cols=12; rows=8; wells=96;}
if(formatPlate=="60-well") 	{hmax = 6; kmax = 11; cols=10; rows=6; wells=60;}
if(formatPlate=="24-well") 	{hmax = 4; kmax = 7; cols=6; rows=4; wells=24;}
if(formatPlate=="12-well") 	{hmax = 3; kmax = 5; cols=4; rows=3; wells=12;}
if(formatPlate=="6-well") 	{hmax = 2; kmax = 4; cols=3; rows=2; wells=6;}
if(formatPlate=="Custom, from well X to well Y"){
	Dialog.create("partial plate overview");
	Dialog.addMessage("FIRST well of the overview: ", 18, "red");
	Dialog.addChoice("               row", letters);
	Dialog.addToSameRow();	
	Dialog.addChoice("   column",numbers);
	Dialog.addMessage("LAST well of the overview: ", 18, "blue");
	Dialog.addChoice("               row", letters);
	Dialog.addToSameRow();	
	Dialog.addChoice("   column",numbers);	
	Dialog.show();	
	firstRowLetter = Dialog.getChoice();
	firstColumnNumber = Dialog.getChoice();
	lastRowLetter = Dialog.getChoice();
	lastColumnNumber = Dialog.getChoice();		
	firstColumn = parseInt(firstColumnNumber);
	lastColumn = parseInt(lastColumnNumber);
	if(firstColumn>lastColumn){exit("Error in selection of first and last columns");}		
	start_h = indexOf("ABCDEFGHIJKLMNOP", firstRowLetter);
	hmax = 1+(indexOf("ABCDEFGHIJKLMNOP", lastRowLetter));
	if(start_h>(hmax-1)){exit("Error in selection of first and last rows");}	
	start_i = firstColumn;
	kmax = 1+lastColumn;
	cols = (lastColumn-firstColumn)+1;
	rows = hmax-start_h;
	wells = cols*rows;
}

// variables related to format of the field of view***************************************************************************
if(fovformat=="4 FOV (2x2)"){fov = 4; colsFov = 2; rowsFov = 2;
	if(fovSetup=="horizontal (standard mode)"){fovOrder = newArray("1","2","3","4");}
	else{fovOrder = newArray("1","2","4","3");}
}
if(fovformat=="9 FOV (3x3)"){fov = 9; colsFov = 3; rowsFov = 3;
	if(fovSetup=="horizontal (standard mode)"){fovOrder = newArray("1","2","3","4","5","6","7","8","9");}
	else{fovOrder = newArray("1","2","3","6","5","4","7","8","9");}
}
if(fovformat=="16 FOV (4x4)"){fov = 16; colsFov = 4; rowsFov = 4;
	if(fovSetup=="horizontal (standard mode)"){fovOrder = newArray("1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16");}
	else{fovOrder = newArray("1","2","3","4","8","7","6","5","9","10","11","12","16","15","14","13");}
}
if(fovformat=="25 FOV (5x5)"){fov = 25; colsFov = 5; rowsFov = 5;
	if(fovSetup=="horizontal (standard mode)"){fovOrder = newArray("1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25");}
	else{fovOrder = newArray("1","2","3","4","5","10","9","8","7","6","11","12","13","14","15","20","19","18","17","16","21","22","23","24","25");}
}
if(fovformat=="1 FOV (1x1)"){fov = 1; colsFov = 1; rowsFov = 1;
	if(fovSetup=="horizontal (standard mode)"){fovOrder = newArray("1");}
	else{fovOrder = newArray("1");}
}
if(fovformat=="Custom"){colsFov = 4; rowsFov = 3;
	Dialog.create("Custom FOV format");
	Dialog.addNumber("Number of columns of FOV:", colsFov);
	Dialog.addNumber("Number of rows of FOV:", rowsFov);
	Dialog.show();
	colsFov = Dialog.getNumber();
	rowsFov = Dialog.getNumber();
	fov = colsFov*rowsFov;
	if(fovSetup=="horizontal (standard mode)"){fovOrder = newArray("1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31","32","33","34","35","36","37","38","39","40","41","42","43","44","45","46","47","48","49","50");}
	else{print("Error: impossible to use serpentine mode with custom FOV setup in this macro"); exit;}
}
if(fovformat=="21 FOV (circle)"){fov = 25; colsFov = 5; rowsFov = 5;
	if(fovSetup=="horizontal (standard mode)"){fovOrder = newArray("0","1","2","3","0","4","5","6","7","08","09","10","11","12","13","14","15","16","17","18","0","19","20","21","0");}
	else{fovOrder = newArray("0","1","2","3","0","4","5","6","7","08","09","10","11","12","13","14","15","16","17","18","0","19","20","21","0");}
}

// getting features of overviews to be created***********************************************************************************
if  (colorOverview=="Yes"){
	choiceBC = newArray("AUTO", "MANUAL");	
	yesORno =newArray("Yes","No");
	listColors =newArray("","Cy3","FITC","DAPI","Cy5","BF","SC");
	if(blueYes)  {defautBlue="DAPI";} else {defautBlue="";}
	if(redYes)   {defautRed="Cy3";} else {defautRed="";}
	if(greenYes) {defautGreen="FITC";} else {defautGreen="";}
	if(cy5Yes)   {defautCy5="Cy5";} else {defautCy5="";}
	if(bfYes)    {defautBF="BF";} else {defautBF="";}
	if(scYes)    {defautBF="SC";} else {defautBF="";}
	Dialog.create("Settings for color overview");
	Dialog.addMessage("Setting for\nBrightness/Contrast:", 20, "blue");	
	Dialog.addRadioButtonGroup("", choiceBC, 2, 1, "MANUAL");
	Dialog.addMessage("Color assignment\nfor each channel", 20, "magenta");	
	Dialog.addChoice("C1     (red)", listColors, defautRed);
	Dialog.addChoice("C2   (green)", listColors, defautGreen);
	Dialog.addChoice("C3    (blue)", listColors, defautBlue);
	Dialog.addChoice("C4    (gray)", listColors, defautBF);
	Dialog.addChoice("C5    (cyan)", listColors);
	Dialog.addChoice("C6 (magenta)", listColors, defautCy5);	
	Dialog.addChoice("C7  (yellow)", listColors);
	Dialog.addMessage("Add well grids\non overview?", 20, "#00b935");
	Dialog.addRadioButtonGroup("", yesORno, 1, 2, "Yes");
	Dialog.addMessage("Substract background?", 20, "#ff6900");	
	Dialog.addCheckbox("Yes", true);
	Dialog.addNumber("Rolling ball radius (pixel):", 50);
	Dialog.addMessage("Keep only final overviews\nin jpeg, not single tifs?", 20, "red");		
	Dialog.addCheckbox("Yes", true);		
	Dialog.show();
	colorSnapshot = Dialog.getRadioButton();	
	c1 = Dialog.getChoice();
	c2 = Dialog.getChoice();
	c3 = Dialog.getChoice();
	c4 = Dialog.getChoice();
	c5 = Dialog.getChoice();
	c6 = Dialog.getChoice();
	c7 = Dialog.getChoice();
	grid = Dialog.getRadioButton();
	substractBackground = Dialog.getCheckbox();
	rolling = Dialog.getNumber();
	deleteTif = Dialog.getCheckbox();
}
							
//generate an array with the list of folders to process, = only the ones containing at least a .tif file************************
var allFoldersToProcess= newArray("");
var foldersOrder=0;
processFolder(imageFolder);
mainList = allFoldersToProcess;
function processFolder(imageFolder){
	mainList = getFileList(imageFolder);
	mainList = Array.sort(mainList);
	counting=0;
	for (p=0; p<mainList.length; p++) { 
		if(counting==0){	
			if (endsWith(mainList[p], ".tif")) {			
				allFoldersToProcess[foldersOrder] = imageFolder;
				foldersOrder++;
				counting++;
			}
	    	if (endsWith(mainList[p], "/")) {
	    	  processFolder(imageFolder + "/" +   mainList[p]);
	    	}
		}
	}
}
// correction of the path in case of // due to empty subfolders****************************************************************
for (u=0; u<mainList.length; u++) {
	if(matches(mainList[u], ".*//.*")){mainList[u] = replace(mainList[u], "//", "/");}
	else{continue}
}	
// generate name for savings by concatenating subfolder names
saveNameList = newArray("");
for (t=0; t<mainList.length; t++) {
	saveNameList[t] = replace(mainList[t], "/", "_");
}
numberOfPlates = mainList.length;
print("Number of plates / folders to process: " + numberOfPlates);

//Get name of the first image***************************************************************************************************
subdir = mainList[0];
if(!endsWith(subdir, "/")){subdir = subdir + "/";}
mainListFirstImage = getFileList(subdir);
mainListFirstImage = Array.sort(mainListFirstImage);
for (im=0; im<mainListFirstImage.length; im++) {
	if(!endsWith(mainListFirstImage[im], ".tif")){continue}
	else{firstImage = mainListFirstImage[im]; break;}
}
//Pixel size determination*********************************************************************************************************
open(subdir + firstImage);
getPixelSize(unit, pixelWidth, pixelHeight);
getDimensions(width, height, channels, slices, frames);
rawPixelSize = pixelWidth;
rawSize = width;
corrPixelSize = (rawSize / sizePixel)*rawPixelSize;
print("corrected pixel size: " + corrPixelSize + "um");
selectWindow("Log");
if (!File.exists(saveFolder + "/snapshots/")){File.makeDirectory(saveFolder + "/snapshots/");}
saveAs("Text", saveFolder + "/snapshots/Pixel_Size.txt");
selectWindow("Log");
selectWindow(firstImage);
run("Close");
//Number of slices determination**************************************************************************************************
if(endsWith(firstImage, "z 1).tif")){zStack = true;}
else if(endsWith(firstImage, "z 01).tif")){zStack = true;}
else{zStack = false;}
if(!matches(firstImage, ".* wv .*") && scYes== false){exit(scMessage);}
if(matches(firstImage, ".* wv .*") && scYes== true){exit(scMessage);}
if(matches(firstImage, ".* time .*")){exit("Sorry, this macro is not compatible with timelapse acquisitions... :-(");}
if(zStack){
	spTitle = split(firstImage, "z");
	tempnbSlices=0;
	for (s=1; s<30; s++){
		if(File.exists     (subdir +  spTitle[0] + "z " + s + ").tif")){tempnbSlices++;} 
		else if(File.exists(subdir + spTitle[0] + "z 0" + s + ").tif")){tempnbSlices++;}											
	}
	nbSlices = tempnbSlices;
	print("The number of slices is: " + nbSlices);
	if(nbSlices == 0) {waitForUser("The calculated number of slices is 0 !!! There is a problem somewhere !!!"); exit }
}
//Propose choice of projection method for Stacks************************************************************************************
choicesZ = newArray("Max Intensity Proj", "Sum Slices Proj", "Gaussian Stack Focuser");
if(zStack){
	Dialog.create("Z stack Projection method");
	Dialog.addChoice("Choice of Projection method for Z stacks:", choicesZ);
	Dialog.show();
	projMeth = Dialog.getChoice();
}

// PROCESSING, CALLING OF FUNCTIONS ************************************************************************************************
print("images opening and montage");
for (u=0; u<listOfChannel.length; u++) {
	name = listOfChannel[u];
	channel = listOfName[u];
	if(zStack) {runChannelZ();}
	else	   {runChannelNoZ();}
}
run("Close All");
if  (colorOverview=="No"){print("END");}
else { 	
	grid_creation();
	rescale_with_coeff(0.15); //setting for coefficient for auto Brightness & Threshold
}
while (nImages>0) {selectImage(nImages); close();
if(deleteTif==true){
	for (p=0; p<mainList.length; p++) {
		barcode = File.getName(saveNameList[p]);
		for (u=0; u<listOfChannel.length; u++) {
			name = listOfChannel[u];
			File.delete(saveFolder + "/snapshots/" + barcode + "_" + name + ".tif");		
		}
	}
}

print("\\Clear");
print("END");
print("Number of overviews created: " + numberOfPlates);

// CUSTOM FUNCTIONS**********************************************************************************************************

// **************************************************************************************************************************
function runChannelNoZ(){
// **************************************************************************************************************************	
	for (p=0; p<mainList.length; p++) {
	CountOpenedImages = 0; 
	subdir = mainList[p]; 
	if(!endsWith(subdir, "/")){subdir = subdir + "/";}
	savedir = saveNameList[p]; 
	barcode = File.getName(savedir);
		for (h = start_h; h<hmax; h++){
			j = letters[h];
			for (i = start_i; i<kmax; i++) {
				for (m = 0; m<fov; m++){
					if(fov<10){fovall = fovOrder[m];}
					else{
						if(m<9){fovall = "0" + fovOrder[m];}
						else{fovall = fovOrder[m];}
					}
					if(File.exists(subdir + j + " - " + i + "(fld " + fovall + channel + ").tif")){
						open(subdir + j + " - " + i + "(fld " + fovall + channel + ").tif");
						run("Size...", "width=" + sizePixel + " height=" + sizePixel + " depth=1 constrain average interpolation=Bilinear");
						CountOpenedImages++; continue;
					}
					else if(File.exists(subdir + j + " - 0" + i + "(fld " + fovall + channel + ").tif")){
						open(subdir + j + " - 0" + i + "(fld " + fovall + channel + ").tif");
						run("Size...", "width=" + sizePixel + " height=" + sizePixel + " depth=1 constrain average interpolation=Bilinear");
						CountOpenedImages++; continue;
					}
					else {newImage("empty", "16-bit black", sizePixel, sizePixel, 1);}
				}
			}
		}
		if (CountOpenedImages == 0) {waitForUser("!!!No images have been opened using the current settings!!!"); exit }
		run("Images to Stack", "name=" + name + " title=[] use");
		run("Stack to Image5D", "3rd=z 4th=ch 3rd_dimension_size=" + fov + " 4th_dimension_size=" + wells + " assign");
		run("Make Montage", "columns=" + colsFov + " rows=" + rowsFov + " scale=1.0 first=1 last=" + fov + " increment=1 border=0 use all output copy");
		run("Image5D to Stack");
		if(isOpen("Exception")){selectWindow("Exception"); run("Close");}
	    run("Make Montage...", "columns=" + cols + " rows=" + rows + " scale=1 border=5 use");
	    selectWindow(name);
		run("Close");
		selectWindow(name + " Montage");
		run("Close");
		run("Enhance Contrast", "saturated=0.35");
  		if (!File.exists(saveFolder + "/snapshots/")){File.makeDirectory(saveFolder + "/snapshots/");}  		
  		saveAs("tiff", saveFolder + "/snapshots/" + barcode + "_" + name + ".tif");
  		while (nImages>0) {selectImage(nImages); close();}
	}
}

// **************************************************************************************************************************
function runChannelZ(){
// **************************************************************************************************************************
	for (p=0; p<mainList.length; p++) {
	CountOpenedImages = 0; 
	subdir = mainList[p];
	if(!endsWith(subdir, "/")){subdir = subdir + "/";}
	savedir = saveNameList[p]; 
	barcode = File.getName(savedir);
		for (h = start_h; h<hmax; h++){
			j = letters[h];
			for (i = start_i; i<kmax; i++) {
				for (m = 0; m<fov; m++) {
					if(fov<10){fovall = fovOrder[m];}
					else{
						if(m<9){fovall = "0" + fovOrder[m];}
						else{fovall = fovOrder[m];}
					} 
					for (n = 1; n<nbSlices+1; n++) 	{						
						if (nbSlices<10) {stack = n;}
						else{
							if (n<10) {stack = "0" + n;} 
							else      {stack = n;}
						}
						if(File.exists(subdir + j + " - " + i + "(fld " + fovall + channel + " z " + stack + ").tif")){
								open(subdir + j + " - " + i + "(fld " + fovall + channel + " z " + stack + ").tif");
								run("Size...", "width=" + sizePixel + " height=" + sizePixel + " depth=1 constrain average interpolation=Bilinear");
								CountOpenedImages++; continue;
						}
						else if(File.exists(subdir + j + " - 0" + i + "(fld " + fovall + channel + " z " + stack + ").tif")){
								open(subdir + j + " - 0" + i + "(fld " + fovall + channel + " z " + stack + ").tif");
								run("Size...", "width=" + sizePixel + " height=" + sizePixel + " depth=1 constrain average interpolation=Bilinear");
								CountOpenedImages++; continue;
						}
						else {	newImage("emptyfld", "16-bit black", sizePixel, sizePixel, 1);}
					}
					run("Images to Stack", "name=StackGrouped title=fld use");										
					if (projMeth == "Max Intensity Proj"){run("Z Project...", "projection=[Max Intensity]");}
					if (projMeth == "Sum Slices Proj"){run("Z Project...", "projection=[Sum Slices]");}
					if (projMeth == "Gaussian Stack Focuser"){run("Gaussian-based stack focuser", "radius_of_gaussian_blur=3"); run("16-bit");}														
					selectWindow("StackGrouped");
					run("Close");
				}	
			}
		}
		if (CountOpenedImages == 0) {waitForUser("!!!No images have been opened using the current settings!!!"); exit }
		run("Images to Stack", "name=" + name + " title=[] use");
		run("Stack to Image5D", "3rd=z 4th=ch 3rd_dimension_size=" + fov + " 4th_dimension_size=" + wells + " assign");
		run("Make Montage", "columns=" + colsFov + " rows=" + rowsFov + " scale=1.0 first=1 last=" + fov + " increment=1 border=0 use all output copy");
		run("Image5D to Stack");
		if(isOpen("Exception")){selectWindow("Exception"); run("Close");}		
		run("Make Montage...", "columns=" + cols + " rows=" + rows + " scale=1 border=5 use");
		selectWindow(name);
		run("Close");
		selectWindow(name + " Montage");
		run("Close");
		run("Enhance Contrast", "saturated=0.35");
		if (!File.exists(saveFolder + "/snapshots/")){File.makeDirectory(saveFolder + "/snapshots/");}  		
		saveAs("tiff", saveFolder + "/snapshots/" + barcode + "_" + name + ".tif");
		while (nImages>0) {selectImage(nImages); close();
		}
	}
}

// **************************************************************************************************************************
function rescale_with_coeff(coeff){
// **************************************************************************************************************************	
	for (p=0; p<mainList.length; p++) {
		if (p==0){print("Creation of color snapshots with grids");}
		savedir = saveNameList[p]; 
	 	barcode = File.getName(savedir);
	 	for (q=0; q<listOfChannel.length; q++) {
	 		name = listOfChannel[q];
			open(saveFolder + "/snapshots/" + barcode + "_" + name + ".tif");
			rename(name);
			if (substractBackground){run("Subtract Background...", "rolling=" + rolling);}
			if  (colorSnapshot=="AUTO"){
				getMinAndMax(min, max);
				minc=min*coeff;
				maxc=max*coeff;
				setMinAndMax(minc, maxc);
			}
	 	}
		if(c1==""){C1="";} else{C1="c1=["+c1+"] ";}
		if(c2==""){C2="";} else{C2="c2=["+c2+"] ";}
		if(c3==""){C3="";} else{C3="c3=["+c3+"] ";}
		if(c4==""){C4="";} else{C4="c4=["+c4+"] ";}
		if(c5==""){C5="";} else{C5="c5=["+c5+"] ";}
		if(c6==""){C6="";} else{C6="c6=["+c6+"] ";}
		if(c7==""){C7="";} else{C7="c7=["+c7+"] ";}	 
		run("Merge Channels...", C1+C2+C3+C4+C5+C6+C7+" create");
		if  (colorSnapshot=="MANUAL"){
			if (p==0){
				print("Manual setting for Brightness & Contrast");
				setBatchMode("exit and display");
				run("Brightness/Contrast...");		
				waitForUser("Brightness/Contrast setting", "Please set manually the Brightness & Contrast for each channel, then click ok when done...");
				setBatchMode("hide");
				limit_min = newArray("");
				limit_max = newArray("");
				for (i = 1; i <= nSlices; i++) {
		    		setSlice(i);
		   			getMinAndMax(min, max);
		   			limit_min[i]=min;
		   			limit_max[i]=max;
				}
			limit_minG = Array.copy(limit_min);
			limit_maxG = Array.copy(limit_max);
			}
			getDimensions(width, height, channels, slices, frames);		
			for (i = 1; i <= nSlices; i++) {setSlice(i); setMinAndMax(limit_minG[i], limit_maxG[i]);}
		}
		getDimensions(width, height, channels, slices, frames);
		run("RGB Color");
		title2 = getTitle();
		selectWindow("montage_grids");
		run("Duplicate...", "title=copy_montage_grids");
		run("Size...", "width=width height=height depth=1 interpolation=Bilinear");
		run("Convert to Mask");
		run("Create Selection");
		selectWindow(title2);
		run("Restore Selection");
		run("Overlay Options...", "stroke=white width=1 fill=white set");
		run("Add Selection...");
		run("Flatten");
		selectWindow(title2);
		saveAs("jpeg", saveFolder + "/snapshots/" + barcode + ".jpg");
		selectWindow("montage_grids");
		close("\\Others");
	}
}

// **************************************************************************************************************************
function grid_creation(){
// **************************************************************************************************************************
	print("Creation of the grid");
	if(formatPlate=="60-well"){
		for (h = 1; h<hmax+1; h++){
			j = letters[h];
			for (k = 2; k<kmax+1; k++) {
				if (k<10) {i = "0" + k;}
				else 	  {i = k;}
				newImage("temp", "16-bit black", 300, 300, 1);
				rename("well"+ j + i);	
				run("Label...", "format=Text starting=0 interval=1 x=5 y=5 font=50 text=" + j + i + "  range=1-1 use use_text");
				run("Flatten");
				selectWindow("well"+j + i);
				run("Close");
			}
		}
	}
	else{
		for (h = start_h; h<hmax; h++){
			j = letters[h];
			for (k = start_i; k<kmax; k++) {
				if (k<10) {	i = "0" + k;}
				else 	  {i = k;}
				newImage("temp", "16-bit black", 300, 300, 1);
				rename("well"+ j + i);	
				run("Label...", "format=Text starting=0 interval=1 x=5 y=5 font=50 text=" + j + i + "  range=1-1 use use_text");
				run("Flatten");
				selectWindow("well"+j + i);
				run("Close");
			}
		}
	}
	run("Images to Stack", "name=Stack title=well use");
	if(grid=="Yes"){run("Make Montage...", "columns=" + cols + " rows=" + rows + " scale=1 border=2 font=20 use"); rename("montage_grids");}
	if(grid=="No") {run("Make Montage...", "columns=" + cols + " rows=" + rows + " scale=1 border=0 font=20 use"); rename("montage_grids");}
	selectWindow("Stack");
	run("Close");
}
// **************************************************************************************************************************





