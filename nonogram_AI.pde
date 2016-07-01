int gridWidth = 30;
int gridHeight =30;
boolean hasError = false;
String question[][] = new String[2][gridWidth+gridHeight];
byte[][] answer = new byte[gridWidth][gridHeight];
int counter;


void setup() {
  size(600, 600);
  String lines[] = loadStrings("question_7.txt");
  for (int i=0; i<lines.length; i++) {
    if (i<gridWidth) question[0][i] = lines[i];
    else  question[1][i-gridWidth] = lines[i];
    println(i, lines[i]);
  }

  background(255);
  strokeWeight(3);
  rect(200, 200, 350, 350);
  for (int i=0; i<gridWidth; i++) {
    for (int j=0; j<gridHeight; j++) {
      strokeWeight(0.5);
      noFill();
      rect(200+350/gridWidth*i, 200+350/gridHeight*j, 350/gridWidth, 350/gridHeight);
    }
    strokeWeight(3);
    rect(50, 200+350/gridHeight*i, 150, 350/gridHeight);
    rect(200+350/gridWidth*i, 50, 350/gridWidth, 150);
    textAlign(RIGHT, CENTER);
    fill(0);
    textSize(10);
    text(join(question[0][i].split(" "), "  "), 190, 200+350/gridHeight*(i+0.5));
    textAlign(CENTER, BOTTOM);
    text(join(question[1][i].split(" "), '\n'), 200+350/gridWidth*(i+0.5), 190);
  }
}

void draw() {
}

void keyPressed() {
  if (keyCode==ENTER) counter=counter>1?0:counter+1;

  if (counter == 0) for (int x=0; x<gridWidth; x++) fillGrid(true, x);

  if (counter ==1) for (int y=0; y<gridHeight; y++) fillGrid(false, y);
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
  if (allPossible.length==0) {
    println("Error due to no suitable filling");
    println(question[_isHorizontal?0:1][_colIndex]);
    return;
  }
  for (int i=0; i<(_isHorizontal?gridWidth:gridHeight); i++) {
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
          rect(200+350/gridWidth*i, 200+350/gridHeight*_colIndex, 350/gridWidth, 350/gridHeight);
        } else {
          answer[_colIndex][i]=127;
          rect(200+350/gridWidth*_colIndex, 200+350/gridHeight*i, 350/gridWidth, 350/gridHeight);
        }
      }
      if (toFill == '1') {
        strokeWeight(0.5);
        fill(0);
        if (_isHorizontal) {
          answer[i][_colIndex]=1;
          rect(200+350/gridWidth*i, 200+350/gridHeight*_colIndex, 350/gridWidth, 350/gridHeight);
        } else {
          answer[_colIndex][i]=1;
          rect(200+350/gridWidth*_colIndex, 200+350/gridHeight*i, 350/gridWidth, 350/gridHeight);
        }
      }
    }
  }
}