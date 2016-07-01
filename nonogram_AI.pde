int gridWidth = 30;
int gridHeight = 25;
boolean hasError = false;
int maxPossibility = 0;
double a=0;//for checking complexity
String question[][] = new String[2][gridWidth+gridHeight];
byte[][] answer = new byte[gridWidth][gridHeight];
int counter=1;


void setup() {
  size(700, 700); 
  String lines[] = loadStrings("question_8.txt");
  for (int i=0; i<lines.length; i++) {
    if (i<gridHeight) question[0][i] = lines[i];
    else  question[1][i-gridHeight] = lines[i];
  }
  background(255);
  strokeWeight(3);
  rect(200, 200, 450, 450);
  for (int i=0; i<gridWidth; i++) {
    for (int j=0; j<gridHeight; j++) {
      strokeWeight(0.5);
      noFill();
      rect(200+450/gridWidth*i, 200+450/gridHeight*j, 450/gridWidth, 450/gridHeight);
    }
    strokeWeight(3);
    rect(200+450/gridWidth*i, 50, 450/gridWidth, 150);
    fill(0);
    textSize(10);
    textAlign(CENTER, BOTTOM);
    text(join(question[1][i].split(" "), '\n'), 200+450/gridWidth*(i+0.5), 190);
  }
  for (int j =0; j<gridHeight; j++) {
    noFill();
    rect(50, 200+450/gridHeight*j, 150, 450/gridHeight);
    fill(0);
    textSize(10);
    textAlign(RIGHT, CENTER);
    text(join(question[0][j].split(" "), "  "), 190, 200+450/gridHeight*(j+0.5));
  }
}

void draw() {
}

void keyPressed() {
  if (keyCode==ENTER) {
    counter=(counter==0)?1:0;

    if (counter == 0) for (int x=0; x<gridHeight; x++) fillGrid(true, x);

    if (counter == 1) for (int y=0; y<gridWidth; y++) fillGrid(false, y);
    
    println(a);//for checking complexity
  }
}

String findAllPossible(boolean isHorizontal, int colIndex) {
  int maxGrid = isHorizontal?gridWidth:gridHeight;
  String[] hintstrs = question[isHorizontal?0:1][colIndex].split(" ");
  int[] hints = {};
  int sum = 0;
  for (int i=0; i<hintstrs.length; i++) {
    hints = append(hints, int(hintstrs[i]));
    sum += hints[i];
  }
  sum+=hints.length-1;
  if (maxGrid<sum) {
    hasError=true;
    println("Sum exceeds the maximum grid numbers");
    return "";
  }
  int[] countingZero = new int[hints.length+1];
  countingZero[countingZero.length-1] = maxGrid-sum;
  boolean finished = false;
  String overallFill = "";
  while (!finished) {
    String wayToFill = "";
    for (int i=0; i<countingZero.length; i++) {
      for (int dummy=0; dummy<countingZero[i]; dummy++) {
        wayToFill+="0";
      }
      if (i<hints.length) {
        for (int dummy=0; dummy<hints[i]; dummy++) {
          wayToFill+="1";
        }
        if (i<hints.length-1) {
          wayToFill+="0";
        }
      }
    }
    if (isMatchedCurrent(wayToFill, isHorizontal, colIndex)) {
      if (overallFill != "") {
        for (int j=0; j<wayToFill.length(); j++) {
          if (overallFill.charAt(j)!= wayToFill.charAt(j)) {
            overallFill = overallFill.substring(0, j)+"2"+overallFill.substring(j+1);
            if (overallFill.indexOf("0")==-1&& overallFill.indexOf("1")==-1) {
              return overallFill;
            }
          }
        }
      } else {
        overallFill = wayToFill;
      }
    }
    if (countingZero[0]==maxGrid-sum) {
      finished = true;
      break;
    }
    int digit = countingZero.length-1;
    if (countingZero[digit]>0) {
      countingZero[digit]--;
      countingZero[digit-1]++;
    } else {
      boolean canContinue = false;
      for (int j=digit; j>0 && !canContinue; j--) {
        if (countingZero[j]>0) {
          countingZero[j-1]++;
          countingZero[j]=0;
          int lastValue = maxGrid-sum;
          for (int k=0; k<j; k++) {
            lastValue-=countingZero[k];
          }
          countingZero[digit] = lastValue;
          canContinue = true;
        }
      }
    }
  }
  return overallFill;
}

boolean isMatchedCurrent(String attemptStr, boolean _isHorizontal, int _colIndex) {
  for (int i=0; i<(_isHorizontal?gridWidth:gridHeight); i++) {
    byte filledGrid = _isHorizontal?answer[i][_colIndex]:answer[_colIndex][i];
    if (filledGrid==1 && attemptStr.charAt(i)!='1') {
      return false;
    }
    if (filledGrid==127 && attemptStr.charAt(i)!='0') {
      return false;
    }
  }
  return true;
}

void fillGrid(boolean _isHorizontal, int _colIndex) {
  String fillway = findAllPossible(_isHorizontal, _colIndex);
  for (int i=0; i<(_isHorizontal?gridWidth:gridHeight); i++) {
    if (_isHorizontal?answer[i][_colIndex]!=0:answer[_colIndex][i]!=0) continue;
    if (fillway.charAt(i)!='2') {
      strokeWeight(0.5);
      if (fillway.charAt(i) == '0') {
        fill(180);
        if (_isHorizontal) {
          answer[i][_colIndex]=127;
          rect(200+450/gridWidth*i, 200+450/gridHeight*_colIndex, 450/gridWidth, 450/gridHeight);
        } else {
          answer[_colIndex][i]=127;
          rect(200+450/gridWidth*_colIndex, 200+450/gridHeight*i, 450/gridWidth, 450/gridHeight);
        }
      }
      if (fillway.charAt(i) == '1') {
        fill(0);
        if (_isHorizontal) {
          answer[i][_colIndex]=1;
          rect(200+450/gridWidth*i, 200+450/gridHeight*_colIndex, 450/gridWidth, 450/gridHeight);
        } else {
          answer[_colIndex][i]=1;
          rect(200+450/gridWidth*_colIndex, 200+450/gridHeight*i, 450/gridWidth, 450/gridHeight);
        }
      }
    }
  }
}