int gridWidth = 30;
int gridHeight = 30;
boolean hasError = false;
int maxPossibility = 0;
double a=0;
byte[][] answer = new byte[gridWidth][gridHeight];
void setup() {
  size(700, 700);
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
    rect(50, 200+450/gridHeight*i, 150, 450/gridHeight);
    rect(200+450/gridWidth*i, 50, 450/gridWidth, 150);
    textAlign(RIGHT, CENTER);
    fill(0);
    textSize(10);
    text(join(question[0][i].split(" "), "  "), 190, 200+450/gridHeight*(i+0.5));
    textAlign(CENTER, BOTTOM);
    text(join(question[1][i].split(" "), '\n'), 200+450/gridWidth*(i+0.5), 190);
  }
}

void draw() {
}
void keyPressed() {
  if (keyCode==ENTER) {
    for (int x=0; x<gridWidth; x++) {
      fillGrid(true, x);
    }
    for (int y=0; y<gridHeight; y++) {
      fillGrid(false, y);
    }
  }
  println(a);
}

String[] findAllPossible(boolean isHorizontal, int colIndex) {
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
    return new String[0];
  }
  String[] allValue = {};
  int[] countingZero = new int[hints.length+1];
  countingZero[countingZero.length-1] = maxGrid-sum;
  boolean finished = false;
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
      allValue=append(allValue, wayToFill);
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
  return allValue;
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
  String[] allPossible = findAllPossible(_isHorizontal, _colIndex);
  if(allPossible.length>maxPossibility){
    maxPossibility = allPossible.length;
    //println(_isHorizontal?0:1, _colIndex,maxPossibility);
  }
  if (allPossible.length==0) {
    println("Error due to no suitable filling");
    println(question[_isHorizontal?0:1][_colIndex]);
    return;
  }
  for (int i=0; i<(_isHorizontal?gridWidth:gridHeight); i++) {
    if(_isHorizontal?answer[i][_colIndex]!=0:answer[_colIndex][i]!=0) continue;
    boolean canFill = true;
    char toFill = allPossible[0].charAt(i);
    for (int j=1; j<allPossible.length && canFill; j++) {
      if (allPossible[j].charAt(i)!=toFill) {
        canFill = false;
      }
    }
    if (canFill) {
      if (toFill == '0') {
        strokeWeight(0.5);
        fill(180);
        if (_isHorizontal) {
          answer[i][_colIndex]=127;
          rect(200+450/gridWidth*i, 200+450/gridHeight*_colIndex, 450/gridWidth, 450/gridHeight);
        } else {
          answer[_colIndex][i]=127;
          rect(200+450/gridWidth*_colIndex, 200+450/gridHeight*i, 450/gridWidth, 450/gridHeight);
        }
      }
      if (toFill == '1') {
        strokeWeight(0.5);
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