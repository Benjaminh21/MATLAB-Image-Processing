%Project%
%Author: Benjamin Terrill%
%Students ID: 15622143%
%Date: 31/10/2019%

%Import Data%

numImages = 24;
A = cell(numImages, 1);
B = cell(numImages, 1);

%Creating variables for the names of files that need to be writen to or loaded in%
filenameWrite = "RawData.xlsx";
filename_template = 'template.xlsx';
filename_groundtruth = 'GroundTruth.xlsx';
%filename_groundtruth = 'testTruth.xlsx';
copyfile(filename_template, filenameWrite);

%imagefiles = imread('images/im1.jpg');
ConfidenceScoreList = zeros(numImages,1);
ConfidenceAverageListHigh = zeros(numImages,1);
ConfidenceAverageListLow = zeros(numImages,1);
highConfidence = 0;
lowConfidence = 0;

for i = 1:numImages
    %Loading in the next image%
    filename = "images/im (" + i + ").jpg";
    loadim = imread(filename);
    colourReciept = loadim;
    colourReciept = imresize (colourReciept, 3);
    
    %Detecting text in the image and image pre-processing%
    greyReciept = rgb2gray(colourReciept); %Convert to greyscale image%
    BWReciept = imbinarize(colourReciept);
    BWReciept = imdilate(BWReciept, strel('square',1));

    
    %Storing the OCR results%
    A{i} = ocr(BWReciept);
    B{i} = A{i, 1}.Words;
    
    temp = ocr(BWReciept);
    % Find characters with low and high confidence.
    highConfidenceIdx = temp.CharacterConfidences >= 0.6;
    lowConfidenceIdx = temp.CharacterConfidences < 0.6;
    
    len = length(highConfidenceIdx);
   
    for q = 1:len
        if highConfidenceIdx(q) == 1
            highConfidence = highConfidence + 1;
        else
            lowConfidence = lowConfidence + 1;
        end
        ConfidenceScoreList(i) = highConfidence;
    end
    
    %Here I get the average high and low confidence scores based on the total divided by the lenght on the reciept%
    ConfidencePercentageHigh = highConfidence/len;
    ConfidencePercentageHigh = ConfidencePercentageHigh * 100;
    
    ConfidencePercentageLow = 100 - ConfidencePercentageHigh;
    
    ConfidenceAverageListHigh(i) = ConfidencePercentageHigh;
    ConfidenceAverageListLow(i) = ConfidencePercentageLow;
    
    %These results will the output for the user at the end%
    
    highConfidence = 0;
    
   
    %Displaying example image after image pre-processing%
    if i == numImages
        %figure; imshowpair(colourReciept, BWReciept,'montage');
        
        example = ocr(BWReciept)
        
        wordBox = example.WordBoundingBoxes(:,:);     %Creating a box around a word in image%
        figure; 
        wordDisplay = insertObjectAnnotation(greyReciept, 'rectangle', wordBox, example.WordConfidences); %Displays the character confidences next to each word%
        imshow(wordDisplay);   
        
        
        highConfidenceIdxtest = example.CharacterConfidences > 0.6;
        
        % Find characters with low confidence.
        lowConfidenceIdxtest = example.CharacterConfidences < 0.5;
        

        % Get the bounding box locations of the low confidence characters.
        lowConfBBoxes = example.CharacterBoundingBoxes(lowConfidenceIdxtest, :);

        % Get confidence values.
        lowConfVal = example.CharacterConfidences(lowConfidenceIdxtest);
        
        % Annotate image with character confidences.
        str      = sprintf('confidence = %f', lowConfVal);
        Ilowconf = insertObjectAnnotation(colourReciept,'rectangle',lowConfBBoxes,str);

        %figure; imshow(Ilowconf);
    end
end


%Find number or rows in each cell array%
RowSizes = cellfun('length', B);
maxlen = max(RowSizes);

B1 = vertcat(B{:});

%Writing the data to a xlsx file. Each reciept is written on new columns%
%To do this each column has to have the same number of rows%
%Fill unneeded rows with NaN value%
w = 'A':'Z';
for k = 1:numImages
  range=[w(k) '1:' w(k) num2str(200)];
  x=B{k, 1};
  xlswrite(filenameWrite,x,range);
end


%Creating two tables too store the OCR data and the ground truth%
T = readtable(filenameWrite)
T2 = readtable(filename_groundtruth)


%Compare the two tables%
%Diff = setdiff(T(:, 2), T2(:, 2))

%Create an array that will store the Accuracy score for each image%
%Filled with 0's to start%
AccuracyScoreList = zeros(numImages,1);

%Loop to find the difference between OCR data and ground truth for each image%
for i = 1:numImages
    Diff = setdiff(T(:, i), T2(:, i));
    result_length = size(A{i, 1}.Words);
    ground_truth_length = size(T2, i) + 1;
    total_correct = result_length - size(Diff, 1);
    
    %Adds accuracy score to list%
    AccuracyScoreList(i) = total_correct/result_length;
end

%Prints out the scores to the user%
AccuracyScoreList
ConfidenceAverageListHigh
ConfidenceAverageListLow













