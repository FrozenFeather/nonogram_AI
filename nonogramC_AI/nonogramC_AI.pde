int gridWidth = 30;
int gridHeight = 30;
boolean hasError = false;
int maxPossibility = 0;
boolean showCross = false;
double a=0;//for checking complexity
String question[][] = new String[2][max(gridWidth, gridHeight)];
byte[][] answer = new byte[gridWidth][gridHeight];
boolean[][][] banned = new boolean[gridWidth][gridHeight][10];
int counter=1;
char[] colorIndex = {};
color[] colors = {};

void setup() {
  size(700, 700); 
  String lines[] = loadStrings("question_c_3.txt");
  int currentLine = 0;
  for (int i=0; i<lines.length; i++) {
    if (lines[i].length()==0) continue;
    switch(lines[i].charAt(0)) {
    case '#':
      gridWidth = int(trim(lines[i].substring(1).split(",")[0]));
      gridHeight = int(trim(lines[i].split(",")[1]));
      break;
    case '+':
      colorIndex = append(colorIndex, lines[i].charAt(1));
      colors = append(colors, unhex("FF"+lines[i].substring(3)));
      break;
    default:
      if (currentLine<gridHeight) question[0][currentLine] = lines[i];
      else  question[1][currentLine-gridHeight] = lines[i];
      currentLine++;
      break;
    }
  }
  background(255);
  strokeWeight(3);
  rect(200, 200, 450, 450);
  for (int i=0; i<gridWidth; i++) {
    for (int j=0; j<gridHeight; j++) {
      strokeWeight(0.5);
      noFill();
      rect(200.0+450.0/gridWidth*i, 200.0+450.0/gridHeight*j, 450.0/gridWidth, 450.0/gridHeight);
    }
    strokeWeight(3);
    rect(200.0+450.0/gridWidth*i, 50, 450.0/gridWidth, 150);
    fill(0);
    textSize(12);
    textAlign(CENTER, BOTTOM);
    String[] index = question[1][i].split(" ");
    for (int n=0; n<index.length; n++) {
      fill(colors[getIndex(colorIndex, index[index.length-n-1].charAt(0))]);
      text(index[index.length-n-1].substring(1), 200.0+450.0/gridWidth*(i+0.5), 190-n*25);
    }
  }
  for (int j =0; j<gridHeight; j++) {
    noFill();
    rect(50, 200.0+450.0/gridHeight*j, 150, 450.0/gridHeight);
    fill(0);
    textSize(12);
    textAlign(RIGHT, CENTER);
    String[] index = question[0][j].split(" ");
    for (int n=0; n<index.length; n++) {
      fill(colors[getIndex(colorIndex, index[index.length-n-1].charAt(0))]);
      text(index[index.length-n-1].substring(1), 190-n*25, 200.0+450.0/gridHeight*(j+0.5));
    }
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
  int sum = 0;
  char lastColor = ' ';
  for (int i=0; i<hintstrs.length; i++) {
    sum += int(hintstrs[i].substring(1));
    if (hintstrs[i].charAt(0) == lastColor) {
      sum++;
    }
    lastColor = hintstrs[i].charAt(0);
  }
  if (maxGrid<sum) {
    hasError=true;
    println("Sum exceeds the maximum grid numbers");
    return "";
  }
  int[] countingZero = new int[hintstrs.length+1];
  countingZero[countingZero.length-1] = maxGrid-sum;
  boolean finished = false;
  String overallFill = "";
  a=0;
  boolean available[][][] = new boolean[gridWidth][gridHeight][colors.length];
  while (!finished) {
    String wayToFill = "";
    lastColor=' ';
    for (int i=0; i<countingZero.length; i++) {
      for (int dummy=0; dummy<countingZero[i]; dummy++) {
        wayToFill+="0";
      }
      if (i<hintstrs.length) {
        if (hintstrs[i].charAt(0) == lastColor) {
          wayToFill+="0";
        }
        lastColor = hintstrs[i].charAt(0);
        for (int dummy=0; dummy<int(hintstrs[i].substring(1)); dummy++) {
          wayToFill+=str(getIndex(colorIndex, hintstrs[i].charAt(0))+1);
        }
      }
    }
    if (isMatchedCurrent(wayToFill, isHorizontal, colIndex)) {
      for (int j=0; j<wayToFill.length(); j++) {
        if (wayToFill.charAt(j)!='0') {
          if (isHorizontal) {
            available[j][colIndex][int(str(wayToFill.charAt(j)))-1]=true;
          } else {
            available[colIndex][j][int(str(wayToFill.charAt(j)))-1]=true;
          }
        }
      }
      if (overallFill != "") {
        String allFail = "";
        for (int j=0; j<wayToFill.length(); j++) {
          if (overallFill.charAt(j)!= wayToFill.charAt(j)) {
            overallFill = overallFill.substring(0, j)+str(colorIndex.length+1)+overallFill.substring(j+1);
          }
          allFail += str(colorIndex.length+1);
        }
        if (overallFill==allFail) {
          finished = true;
          break;
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
  for (int i = 0; i<maxGrid; i++) {
    for (int c = 0; c<colors.length; c++) {
      if (isHorizontal && !available[i][colIndex][c]) {
        banned[i][colIndex][c+1] = true;
      } else if (!isHorizontal && !available[colIndex][i][c]) {
        banned[colIndex][i][c+1] = true;
      }
    }
  }
  println(a);
  return overallFill;
}

boolean isMatchedCurrent(String attemptStr, boolean _isHorizontal, int _colIndex) {
  for (int i=0; i<(_isHorizontal?gridWidth:gridHeight); i++) {
    byte filledGrid = _isHorizontal?answer[i][_colIndex]:answer[_colIndex][i];
    if (filledGrid!=0 && filledGrid!=127 && attemptStr.charAt(i)!=str(filledGrid).charAt(0)) {
      return false;
    }
    if (filledGrid==127 && attemptStr.charAt(i)!='0') {
      return false;
    }
    if (_isHorizontal?banned[i][_colIndex][int(str(attemptStr.charAt(i)))]:banned[_colIndex][i][int(str(attemptStr.charAt(i)))]) {
      return false;
    }
  }
  return true;
}

void fillGrid(boolean _isHorizontal, int _colIndex) {
  String fillway = findAllPossible(_isHorizontal, _colIndex);
  for (int i=0; i<(_isHorizontal?gridWidth:gridHeight); i++) {
    if (_isHorizontal?answer[i][_colIndex]!=0:answer[_colIndex][i]!=0) continue;
    if (fillway.length()==0) {
      println("Error due to no suitable filling ", _isHorizontal?"H":"V", _colIndex);
      return;
    }
    if (int(str(fillway.charAt(i)))!=colorIndex.length+1) {
      strokeWeight(0.5);
      if (fillway.charAt(i) == '0') {
        if (showCross) fill(200);
        else fill(255);
        if (_isHorizontal) {
          answer[i][_colIndex]=127;
          rect(200.0+450.0/gridWidth*i, 200.0+450.0/gridHeight*_colIndex, 450.0/gridWidth, 450.0/gridHeight);
        } else {
          answer[_colIndex][i]=127;
          rect(200.0+450.0/gridWidth*_colIndex, 200.0+450.0/gridHeight*i, 450.0/gridWidth, 450.0/gridHeight);
        }
      } else {
        fill(colors[int(str(fillway.charAt(i)))-1]);
        if (_isHorizontal) {
          answer[i][_colIndex]=(byte)int(str(fillway.charAt(i)));
          rect(200.0+450.0/gridWidth*i, 200.0+450.0/gridHeight*_colIndex, 450.0/gridWidth, 450.0/gridHeight);
        } else {
          answer[_colIndex][i]=(byte)int(str(fillway.charAt(i)));
          rect(200.0+450.0/gridWidth*_colIndex, 200.0+450.0/gridHeight*i, 450.0/gridWidth, 450.0/gridHeight);
        }
      }
    }
  }
}

int getIndex(char[] array, char value) {
  for (int a=0; a<array.length; a++) {
    if (array[a]==value) {
      return a;
    }
  }
  return -1;
}