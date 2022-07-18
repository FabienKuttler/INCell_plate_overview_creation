
// **************************************************************************************************************************
// **************************************************************************************************************************
//	*************************************************************************************************************************
//	*************************************************************************************************************************
//	
//                                     Macro for general fluo plate OVERVIEW generation
//                           for images acquired with INCell automated fluorescence microscope
//                           Fabien Kuttler, 2022, EPFL-SV-PTECH-PTCB BSF, http://bsf.epfl.ch
//
//
//	*************************************************************************************************************************
//	*************************************************************************************************************************
// **************************************************************************************************************************
// **************************************************************************************************************************

// Get input and output folders**********************************************************************************************
#@ File (label="Raw  images  source  folder", style="directory", persist=true) imageFolder
#@ File (label="Overview destination folder", style="directory", persist=true) saveFolder

// Get conditionnal variables************************************************************************************************
requires("1.52p");
print("Getting information from source folder.......");
if(!File.exists(saveFolder)){File.makeDirectory(saveFolder);}
setBatchMode(true);
var start_h = 0;
var start_i = 1;
run("Colors...", "foreground=white background=black selection=yellow");
letters = newArray("A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P");
numbers = newArray("01","02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24");

// Generate an array with the list of folders to process, = only the ones containing at least a .tif file********************
var allFoldersToProcess= newArray("");
var foldersOrder=0;
processFolder(imageFolder);
mainList = allFoldersToProcess;

// Correction of the path in case of // due to empty subfolders**************************************************************
for (u=0; u<mainList.length; u++) {
	if(matches(mainList[u], ".*//.*")){mainList[u] = replace(mainList[u], "//", "/");}
	else{continue}
}	
// Generate name for savings by concatenating subfolder names****************************************************************
saveNameList = newArray("");
for (t=0; t<mainList.length; t++) {
	saveNameList[t] = replace(mainList[t], "/", "_");
}
numberOfPlates = mainList.length;

// Get name and size of the first image and last image***********************************************************************
subdir = mainList[0];
if(!endsWith(subdir, "/")){subdir = subdir + "/";}
mainListFirstImage = getFileList(subdir);
mainListFirstImage = Array.sort(mainListFirstImage);
for (im=0; im<mainListFirstImage.length; im++) {
	if(!endsWith(mainListFirstImage[im], ".tif")){continue}
	if(matches(mainListFirstImage[im], ".*poly.*")){continue}
	else{firstImage = mainListFirstImage[im]; break;}
}
for (im=mainListFirstImage.length-1; im>0; im--) {
	if(!endsWith(mainListFirstImage[im], ".tif")){continue}
	if(matches(mainListFirstImage[im], ".*poly.*")){continue}
	else{lastImage = mainListFirstImage[im]; break;}
}

// Get size of source images in pixels***************************************************************************************
open(subdir + firstImage);
getDimensions(width, height, channels, slices, frames);
close("*");

// Create list of images from the first well*********************************************************************************
listOfImagesFromFirstWell=newArray(0);
if(matches(firstImage, "^[A-Z] - [0-9][0-9].*")){beginning=substring(firstImage, 0, 6);}
else{beginning=substring(firstImage, 0, 5);}
for (p=0; p<mainListFirstImage.length; p++) {
	if(!endsWith(mainListFirstImage[p], ".tif")){continue}
	if(matches(mainListFirstImage[p], ".*poly.*")){continue}	
	if(matches(mainListFirstImage[p], ".*"+beginning+".*")){
		if (contains(listOfImagesFromFirstWell, mainListFirstImage[p])) {continue}
		else {listOfImagesFromFirstWell = Array.concat(listOfImagesFromFirstWell, mainListFirstImage[p]);}		
	}
}

// Get construction of the images names and other information****************************************************************
if(matches(firstImage, ".*fld.*")){fldName = true;} else{fldName = false;}
if(matches(firstImage, ".*wv.*")){wvName = true;} else{wvName = false;}
if(matches(firstImage, "^[A-Z] - [0-9][0-9].*")){colTwoDigits = true;} else{colTwoDigits = false;}
if(fldName && matches(firstImage, ".*fld [0-9][0-9] .*")){fldTwoDigits = true;} else{fldTwoDigits = false;}

// Create list of images from first plate************************************************************************************
listOfImagesFromFirstPlate=newArray(0);
for (im=0; im<mainListFirstImage.length; im++) {
	if(!endsWith(mainListFirstImage[im], ".tif")){continue}
	if(matches(mainListFirstImage[im], ".*poly.*")){continue}
	else{listOfImagesFromFirstPlate = Array.concat(listOfImagesFromFirstPlate, mainListFirstImage[im]);}
}

// Get row and col for each image of first plate*****************************************************************************
listOfRow = newArray(0);
listOfCol = newArray(0);
listOfFld = newArray(0);
for (p=0; p<listOfImagesFromFirstPlate.length; p++) {
	listOfImagesFromFirstPlate[p] = replace(listOfImagesFromFirstPlate[p], " ", "");
	listOfImagesFromFirstPlate[p] = replace(listOfImagesFromFirstPlate[p], ")", "_");
	listOfImagesFromFirstPlate[p] = replace(listOfImagesFromFirstPlate[p], "(", "_");
	listOfRow = Array.concat(listOfRow, substring(listOfImagesFromFirstPlate[p], 0, 1));
	listOfCol = Array.concat(listOfCol, parseFloat(substring(listOfImagesFromFirstPlate[p], 2, indexOf(listOfImagesFromFirstPlate[p], "_"))));
	if(matches(listOfImagesFromFirstPlate[p], ".*fld[0-9][0-9].*")){tempFld = parseFloat(String.trim(substring(listOfImagesFromFirstPlate[p], indexOf(listOfImagesFromFirstPlate[p], "fld")+3, indexOf(listOfImagesFromFirstPlate[p], "fld")+5)));}
	else{tempFld = parseFloat(String.trim(substring(listOfImagesFromFirstPlate[p], indexOf(listOfImagesFromFirstPlate[p], "fld")+3, indexOf(listOfImagesFromFirstPlate[p], "fld")+4)));}
	listOfFld = Array.concat(listOfFld, tempFld);
}
listOfRow = Array.sort(listOfRow);
listOfCol = Array.sort(listOfCol);
listOfFld = Array.sort(listOfFld);
firstRow = listOfRow[0];
lastRow = listOfRow[listOfRow.length-1];
firstColumn = listOfCol[0];
lastColumn = listOfCol[listOfCol.length-1];
endFld = listOfFld[listOfFld.length-1];
if(matches(lastImage, ".*fld.*")){lastFld = endFld;} else {lastFld = 1;}
if(lastRow == firstRow && lastColumn == firstColumn){exit("This macro is not compatible\n(and not really necessary anyway)\nif only one well has been acquired...\nBye bye !!!");}

// Generate the true list of channels found in source folder*****************************************************************
trueListOfChannels = newArray(0);
if (wvName) {
	tempo = newArray(0);
	for (im=0; im<listOfImagesFromFirstWell.length; im++) {
		if(matches(listOfImagesFromFirstWell[im], ".*z.*")){tempo = split(listOfImagesFromFirstWell[im], "z");}
		else {tempo[0] = listOfImagesFromFirstWell[im];}
		channelName = substring(tempo[0], indexOf(tempo[0], "wv"));
		channelName = replace(channelName, "wv ", "");
		channelName = replace(channelName, "..tif", "");
		if (contains(trueListOfChannels, channelName)) {continue}
		else {trueListOfChannels = Array.concat(trueListOfChannels, channelName);}	
	}
}
else {trueListOfChannels[0] = "Single Channel";}

// Control if any of the image files contains 'time'*************************************************************************
for (im=0; im<listOfImagesFromFirstWell.length; im++) {
	if(matches(listOfImagesFromFirstWell[im], ".*time.*")){
		exit("This macro is not compatible with \ntimelapse acquisitions...");
	}
}

// Get plate and fov settings************************************************************************************************
plateChoice = newArray("384-well", "96-well", "60-well", "24-well", "12-well", "6-well", "Custom, from well X to well Y");
fovChoice = newArray("1 FOV (1x1)", "4 FOV (2x2)", "9 FOV (3x3)", "16 FOV (4x4)", "25 FOV (5x5)", "21 FOV (circle)", "Custom"); 
setupChoice = newArray("horizontal (standard mode)", "horizontal serpentine mode"); 
overviewChoice = newArray("Yes", "No"); 
defaultFov = "Custom";
defaultPlate = "Custom, from well X to well Y";
Dialog.create("Settings for plate and FOV format");
Dialog.addMessage("Source folder contains images", 20, "black");
Dialog.addMessage("from well   " + firstRow + firstColumn + "   to well   " + lastRow + lastColumn, 20, "black");
//Dialog.addMessage("first row    " + firstRow + "     ,    first column     " + firstColumn, 12, "black");
//Dialog.addMessage("last row    " + lastRow + "    ,    last  column    " + lastColumn, 12, "black");
if(lastColumn == 24 && lastRow == "P" && firstColumn == 1 && firstRow == "A"){defaultPlate = "384-well";}
if(lastColumn == 12 && lastRow == "H" && firstColumn == 1 && firstRow == "A"){defaultPlate = "96-well";}
if(lastColumn == 6 && lastRow == "D" && firstColumn == 1 && firstRow == "A"){defaultPlate = "24-well";}
if(lastColumn == 4 && lastRow == "C" && firstColumn == 1 && firstRow == "A"){defaultPlate = "12-well";}
if(lastColumn == 3 && lastRow == "B" && firstColumn == 1 && firstRow == "A"){defaultPlate = "6-well";}
if(lastColumn == 11 && lastRow == "G" && firstColumn == 2 && firstRow == "B"){defaultPlate = "60-well";}
Dialog.addMessage("Plate format (suggested: " + defaultPlate + ") :", 20, "red");
Dialog.addRadioButtonGroup("", plateChoice, 7, 1, defaultPlate);
Dialog.addMessage("Nb FOV per well (detected: "+lastFld+") :", 20, "blue");
if(lastFld == 1){defaultFov = "1 FOV (1x1)";}
if(lastFld == 4){defaultFov = "4 FOV (2x2)";}
if(lastFld == 9){defaultFov = "9 FOV (3x3)";}
if(lastFld == 16){defaultFov = "16 FOV (4x4)";}
if(lastFld == 25){defaultFov = "25 FOV (5x5)";}
if(lastFld == 21){defaultFov = "21 FOV (circle)";}
Dialog.addRadioButtonGroup("", fovChoice, 7, 1, defaultFov);	
Dialog.addMessage("Fov setup:", 20, "#00b935");						
Dialog.addChoice("", setupChoice, "horizontal (standard mode)");
Dialog.addMessage("Image Resizing, in pixels :", 20, "#ff6900");	
Dialog.addNumber("", 500, 0, 10, "(the source images are "+height+" pixels)");
Dialog.addMessage("Create a final Multicolor Overview?", 20, "#8900ff");		
Dialog.addRadioButtonGroup("", overviewChoice, 1, 2, "Yes");
Dialog.show();
formatPlate = Dialog.getRadioButton();
fovformat = Dialog.getRadioButton();
fovSetup = Dialog.getChoice();
sizePixel = Dialog.getNumber();
colorOverview = Dialog.getRadioButton();

// Variables related to format of the plate**********************************************************************************
if(formatPlate=="384-well") {hmax = 16; kmax = 25; cols=24; rows=16; wells=384;}
if(formatPlate=="96-well") 	{hmax = 8; kmax = 13; cols=12; rows=8; wells=96;}
if(formatPlate=="60-well") 	{hmax = 7; kmax = 12; cols=10; rows=6; wells=60; start_h = 1; start_i = 2;}
if(formatPlate=="24-well") 	{hmax = 4; kmax = 7; cols=6; rows=4; wells=24;}
if(formatPlate=="12-well") 	{hmax = 3; kmax = 5; cols=4; rows=3; wells=12;}
if(formatPlate=="6-well") 	{hmax = 2; kmax = 4; cols=3; rows=2; wells=6;}
if(formatPlate=="Custom, from well X to well Y"){
	if(firstColumn<10){firstColumnCustom = "0"+firstColumn;} else{firstColumnCustom = firstColumn;}
	if(lastColumn<10){lastColumnCustom = "0"+lastColumn;} else{lastColumnCustom = lastColumn;}
	Dialog.create("partial plate overview");
	Dialog.addMessage("FIRST well of the overview: ", 18, "red");
	Dialog.addChoice("               row", letters, firstRow);
	Dialog.addToSameRow();	
	Dialog.addChoice("   column",numbers, firstColumnCustom);
	Dialog.addMessage("LAST well of the overview: ", 18, "blue");
	Dialog.addChoice("               row", letters, lastRow);
	Dialog.addToSameRow();	
	Dialog.addChoice("   column",numbers, lastColumnCustom);	
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

// Variables related to format of the field of view**************************************************************************
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

// Getting features of overviews to be created*******************************************************************************
choiceBC = newArray("AUTO", "MANUAL");	
yesORno =newArray("Yes","No");
listColors =newArray("","red","green","blue","gray","cyan","magenta","yellow");
Dialog.create("Settings for channel and color overview");
Dialog.addMessage("List of channels in source folder:", 20, "#8900ff");
Dialog.addMessage(" (un)select          /          assign color", 18, "#8900ff");		
for (ch=0; ch<trueListOfChannels.length; ch++) {
	if(matches(trueListOfChannels[ch], ".*(Cy3 - Cy3).*")) {defaultColor = "red";}
	else if(matches(trueListOfChannels[ch], ".*(DAPI).*")) {defaultColor = "blue";}
	else if(matches(trueListOfChannels[ch], ".*(FITC).*")) {defaultColor = "green";}
	else if(matches(trueListOfChannels[ch], ".*(Cy5).*")) {defaultColor = "magenta";}
	else if(matches(trueListOfChannels[ch], ".*(CFP).*")) {defaultColor = "cyan";}
	else if(matches(trueListOfChannels[ch], ".*(YFP).*")) {defaultColor = "yellow";}
	else if(matches(trueListOfChannels[ch], ".*(Bright).*")) {defaultColor = "gray";}
	else if(matches(trueListOfChannels[ch], ".*(Single).*")) {defaultColor = "gray";}
	else {defaultColor = "";}
	Dialog.addCheckbox(trueListOfChannels[ch], true);
	Dialog.addToSameRow();	
	Dialog.addChoice("", listColors, defaultColor);
}
Dialog.addMessage("Setting brightness / contrast:", 20, "blue");	
Dialog.addRadioButtonGroup("", choiceBC, 1, 2, "MANUAL");		
Dialog.addMessage("Add well grids on overview?", 20, "#00b935");
Dialog.addRadioButtonGroup("", yesORno, 1, 2, "Yes");
Dialog.addMessage("Substract background?", 20, "#ff6900");	
Dialog.addCheckbox("Yes", true);
Dialog.addNumber("Rolling ball radius (pixel):", 50);
Dialog.addMessage("Keep only final overviews in jpeg\n(but not individual tifs?)", 20, "red");		
Dialog.addCheckbox("Yes", true);		
Dialog.show();
listOfChannel = newArray(0);
listOfColor = newArray(0);
listOfName = newArray(0);
listOfChannelNoSpace = newArray(0);
for (ch=0; ch<trueListOfChannels.length; ch++) {
	trCh = Dialog.getCheckbox();
	trCo = Dialog.getChoice();
	if (trCh) {
		modifiedCh = substring(trueListOfChannels[ch], 0, indexOf(trueListOfChannels[ch], " "));
		listOfChannel = Array.concat(listOfChannel,modifiedCh);
		if(fldName){modifiedName = " wv " + trueListOfChannels[ch];} else {modifiedName = "wv " + trueListOfChannels[ch];}
		listOfName = Array.concat(listOfName,modifiedName);
		listOfColor = Array.concat(listOfColor, trCo);
		modifiedTrue = replace(trueListOfChannels[ch], " ", "");
		listOfChannelNoSpace = Array.concat(listOfChannelNoSpace,modifiedTrue);
	}
}	
colorSnapshot = Dialog.getRadioButton();	
grid = Dialog.getRadioButton();
substractBackground = Dialog.getCheckbox();
rolling = Dialog.getNumber();
deleteTif = Dialog.getCheckbox();

if (!wvName) {
	listOfChannel = newArray("SC");
	listOfName = newArray("");
	listOfChannelNoSpace = newArray("");
}

// Pixel size determination**************************************************************************************************
open(subdir + firstImage);
getPixelSize(unit, pixelWidth, pixelHeight);
getDimensions(width, height, channels, slices, frames);
rawPixelSize = pixelWidth;
rawSize = width;
corrPixelSize = (rawSize / sizePixel)*rawPixelSize;
print("corrected pixel size: " + corrPixelSize + "um");
selectWindow("Log");
if (!File.exists(saveFolder + "/overviews/")){File.makeDirectory(saveFolder + "/overviews/");}
saveAs("Text", saveFolder + "/overviews/Pixel_Size.txt");
selectWindow("Log");
selectWindow(firstImage);
run("Close");

print("Number of plates / folders to process: " + numberOfPlates);

// For each channel to be processed, determine if Z stacks acquired and number of slices*************************************
zNameList = newArray(0);
zSliceList = newArray(0);
for (u=0; u<listOfChannel.length; u++) {
	patrn = listOfName[u];
	zNameList[u] = false;
	zSliceList[u] = 0;
	for (im=0; im<listOfImagesFromFirstWell.length; im++) {
		if(!matches(listOfImagesFromFirstWell[im], ".*"+patrn+".*")){continue}
		else{
			if(matches(listOfImagesFromFirstWell[im], ".*z.*")){
				zNameList[u] = true;		
				spTitle = split(listOfImagesFromFirstWell[im], "z");
				tempnbSlices=0;
				for (s=1; s<30; s++){
					if(File.exists     (subdir +  spTitle[0] + "z " + s + ").tif")){tempnbSlices++;} 
					else if(File.exists(subdir + spTitle[0] + "z 0" + s + ").tif")){tempnbSlices++;}											
				}
				nbSlices = tempnbSlices;
				zSliceList[u] = nbSlices;
				print("The number of slices for channel ' " + patrn + " ' is: " + nbSlices);
				if(nbSlices == 0) {waitForUser("The calculated number of slices is 0 !!!\nThere is a problem somewhere !!!"); exit }				
								
				break;
				break;
			}
		}
	}
}
zName = contains(zNameList, true);

// Display choice of projection method for Stacks****************************************************************************
choicesZ = newArray("Max Intensity Proj", "Sum Slices Proj", "Gaussian Stack Focuser");
if(zName){
	Dialog.create("Z stack Projection method");
	Dialog.addChoice("Choice of Projection method for Z stacks:", choicesZ);
	Dialog.show();
	projMeth = Dialog.getChoice();
}

// **************************************************************************************************************************
// ******************************************    P  R  O  C  E  S  S  I  N  G    ********************************************
// **************************************************************************************************************************

print("images opening and montage");
for (u=0; u<listOfChannel.length; u++) {
	name = listOfChannelNoSpace[u];
	//name = listOfChannel[u];
	channel = listOfName[u];
	zNameCurrent = zNameList[u];
	nbSlices = zSliceList[u];	
	if(zNameCurrent) {runChannelZ();}
	else	   {runChannelNoZ();}
}
run("Close All");
if  (colorOverview=="No"){print("END");}
else {rescale_with_coeff(0.15);}
while (nImages>0) {selectImage(nImages); close();}
if(deleteTif==true){delete_tifs();}

print("Number of overviews created: " + numberOfPlates);
print("END");

// **************************************************************************************************************************
// *******************************    C  U  S  T  O  M     F  U  N  C  T  I  O  N  S     ************************************
// **************************************************************************************************************************

// **************************************************************************************************************************
function contains(array, value){
// **************************************************************************************************************************
    for (i=0; i<array.length; i++) {
    	if ( array[i] == value ) {return true; break;}   	
    }
    return false;
}	

// **************************************************************************************************************************
function processFolder(imageFolder){
// **************************************************************************************************************************
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

// **************************************************************************************************************************
function delete_tifs(){
// **************************************************************************************************************************
	print("Delete tifs:");
	for (p=0; p<mainList.length; p++) {
		barcode = File.getName(saveNameList[p]);
		for (u=0; u<listOfChannel.length; u++) {
			name = listOfChannelNoSpace[u];
			File.delete(saveFolder + "/overviews/" + barcode + "_" + name + ".tif");	
		}
	}
}

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
					if(colTwoDigits && i<10){icol = "0" + i;}
					else{icol = i;}
					for (m = 0; m<fov; m++){
						if(fldTwoDigits && m<9){fovall = "0" + fovOrder[m];}
						else{fovall = fovOrder[m];}
						if(fldName){field = "fld " + fovall;} else{field = "";}
						if(File.exists(subdir + j + " - " + icol + "(" + field + channel + ").tif")){
							open(subdir + j + " - " + icol + "(" + field + channel + ").tif");
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
  		if (!File.exists(saveFolder + "/overviews/")){File.makeDirectory(saveFolder + "/overviews/");}  		
  		saveAs("tiff", saveFolder + "/overviews/" + barcode + "_" + name + ".tif");
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
					if(colTwoDigits && i<10){icol = "0" + i;}
					else{icol = i;}
					for (m = 0; m<fov; m++) {
						if(fldTwoDigits && m<9){fovall = "0" + fovOrder[m];}
						else{fovall = fovOrder[m];}
						for (n = 1; n<nbSlices+1; n++) 	{						
							if (nbSlices>10 && n<10) {stack = "0" + n;} 
							else {stack = n;}
							if(fldName){field = "fld " + fovall;} else{field = "";}
							if(File.exists(subdir + j + " - " + icol + "(" + field + channel + "z " + stack + ").tif")){ 
								open(subdir + j + " - " + icol + "(" + field + channel + "z " + stack + ").tif");
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
		if (!File.exists(saveFolder + "/overviews/")){File.makeDirectory(saveFolder + "/overviews/");}  		
		saveAs("tiff", saveFolder + "/overviews/" + barcode + "_" + name + ".tif");
		while (nImages>0) {selectImage(nImages); close();
		}
	}
}

// **************************************************************************************************************************
function rescale_with_coeff(coeff){
// **************************************************************************************************************************	
	for (p=0; p<mainList.length; p++) {
		if (p==0){print("Creation of color overviews with grids");}
		savedir = saveNameList[p]; 
	 	barcode = File.getName(savedir);
	 	for (q=0; q<listOfChannel.length; q++) {
	 		//name = listOfChannel[q];
	 		name = listOfChannelNoSpace[q];
			open(saveFolder + "/overviews/" + barcode + "_" + name + ".tif");
			rename(name);
			if (substractBackground){run("Subtract Background...", "rolling=" + rolling);}
			if  (colorSnapshot=="AUTO"){
				getMinAndMax(min, max);
				minc=min*coeff;
				maxc=max*coeff;
				setMinAndMax(minc, maxc);
			}
	 	}
	 	C1=""; C2=""; C3=""; C4=""; C5=""; C6=""; C7="";	
		for (ch=0; ch<listOfChannel.length; ch++) {
			//currentChannel = listOfChannel[ch];
			currentChannel = listOfChannelNoSpace[ch];			
			currentName = listOfName[ch];
			currentColor = listOfColor[ch];
			if(currentColor=="red")    {C1="c1=["+currentChannel+"] ";}
			if(currentColor=="green")  {C2="c2=["+currentChannel+"] ";}
			if(currentColor=="blue")   {C3="c3=["+currentChannel+"] ";}
			if(currentColor=="gray")   {C4="c4=["+currentChannel+"] ";}
			if(currentColor=="cyan")   {C5="c5=["+currentChannel+"] ";}
			if(currentColor=="magenta"){C6="c6=["+currentChannel+"] ";}
			if(currentColor=="yellow") {C7="c7=["+currentChannel+"] ";}
		}
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
		grid_creation();
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
		saveAs("jpeg", saveFolder + "/overviews/" + barcode + ".jpg");
		selectWindow("montage_grids");
		close("\\Others");
	}
}

// **************************************************************************************************************************
function grid_creation(){
// **************************************************************************************************************************
	print("Creation of the grid");
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
	run("Images to Stack", "name=Stack title=well use");
	if(grid=="Yes"){run("Make Montage...", "columns=" + cols + " rows=" + rows + " scale=1 border=2 font=20 use"); rename("montage_grids");}
	if(grid=="No") {run("Make Montage...", "columns=" + cols + " rows=" + rows + " scale=1 border=0 font=20 use"); rename("montage_grids");}
	selectWindow("Stack");
	run("Close");
}
// **************************************************************************************************************************
// **************************************************************************************************************************




