import de.bezier.guido.*;
import java.util.ArrayList;

final int NUM_ROWS = 20;
final int NUM_COLS = 20;
final int NUM_MINES = 60;

MSButton[][] buttons;
ArrayList<MSButton> mines;

boolean gameOver = false;
boolean gameWon = false;

float cellW, cellH;

float restartX, restartY, restartW, restartH;

void setup()
{
  size(600, 650);
  textAlign(CENTER, CENTER);
  Interactive.make(this);

  cellW = 600.0 / NUM_COLS;
  cellH = 600.0 / NUM_ROWS;

  restartW = 160;
  restartH = 40;
  restartX = width/2 - restartW/2;
  restartY = 605;

  restartGame();
}

void restartGame()
{
  gameOver = false;
  gameWon = false;

  buttons = new MSButton[NUM_ROWS][NUM_COLS];
  mines = new ArrayList<MSButton>();

  for (int r = 0; r < NUM_ROWS; r++)
    for (int c = 0; c < NUM_COLS; c++)
      buttons[r][c] = new MSButton(r, c);

  setMines();
}

void draw()
{
  background(0);

  for (int r = 0; r < NUM_ROWS; r++)
    for (int c = 0; c < NUM_COLS; c++)
      buttons[r][c].draw();

  fill(30);
  rect(0, 600, width, 50);

  drawRestartButton();

  if (gameOver)
  {
    fill(255);
    textSize(28);
    text("YOU LOSE", width/2, 625);
  }
  else if (gameWon)
  {
    fill(255);
    textSize(28);
    text("YOU WIN", width/2, 625);
  }
}

void drawRestartButton()
{
  fill(90);
  rect(restartX, restartY, restartW, restartH);
  fill(255);
  textSize(18);
  text("Restart", restartX + restartW/2, restartY + restartH/2);
}

void mousePressed()
{
  if (mouseX >= restartX && mouseX <= restartX + restartW &&
      mouseY >= restartY && mouseY <= restartY + restartH)
  {
    restartGame();
  }
}

void setMines()
{
  mines.clear();
  while (mines.size() < NUM_MINES)
  {
    int r = (int)random(NUM_ROWS);
    int c = (int)random(NUM_COLS);
    MSButton b = buttons[r][c];
    if (!mines.contains(b))
      mines.add(b);
  }
}

boolean isWon()
{
  for (int r = 0; r < NUM_ROWS; r++)
    for (int c = 0; c < NUM_COLS; c++)
      if (!mines.contains(buttons[r][c]) && !buttons[r][c].clicked)
        return false;
  return true;
}

void displayLosingMessage()
{
  gameOver = true;
  for (MSButton b : mines)
  {
    b.clicked = true;
    b.setLabel("X");
  }
}

void displayWinningMessage()
{
  gameWon = true;
  for (MSButton b : mines)
    b.setLabel("✔");
}

boolean isValid(int r, int c)
{
  return r >= 0 && r < NUM_ROWS && c >= 0 && c < NUM_COLS;
}

int countMines(int row, int col)
{
  int numMines = 0;
  for (int dr = -1; dr <= 1; dr++)
    for (int dc = -1; dc <= 1; dc++)
    {
      if (dr == 0 && dc == 0) continue;
      int rr = row + dr;
      int cc = col + dc;
      if (isValid(rr, cc) && mines.contains(buttons[rr][cc]))
        numMines++;
    }
  return numMines;
}

public class MSButton
{
  private int myRow, myCol;
  private float x, y;
  private boolean clicked, flagged;
  private String myLabel;

  public MSButton(int row, int col)
  {
    myRow = row;
    myCol = col;
    x = myCol * cellW;
    y = myRow * cellH;
    myLabel = "";
    flagged = clicked = false;
    Interactive.add(this);
  }

  public void mousePressed()
  {
    if (gameOver || gameWon) return;

    if (mouseButton == RIGHT)
    {
      flagged = !flagged;
      if (!flagged)
      {
        clicked = false;
        myLabel = "";
      }
      else
      {
        clicked = false;
        myLabel = "F";
      }
      return;
    }

    if (flagged || clicked) return;

    clicked = true;

    if (mines.contains(this))
    {
      displayLosingMessage();
      return;
    }

    int n = countMines(myRow, myCol);

    if (n > 0)
    {
      setLabel(n);
    }
    else
    {
      setLabel("");
      for (int dr = -1; dr <= 1; dr++)
        for (int dc = -1; dc <= 1; dc++)
        {
          if (dr == 0 && dc == 0) continue;
          int rr = myRow + dr;
          int cc = myCol + dc;
          if (isValid(rr, cc))
          {
            MSButton nb = buttons[rr][cc];
            if (!nb.clicked && !nb.flagged)
              nb.mousePressed();
          }
        }
    }

    if (!gameWon && isWon())
      displayWinningMessage();
  }

  public void draw()
  {
    stroke(50);

    if (flagged)
      fill(0);
    else if (clicked && mines.contains(this))
      fill(255, 0, 0);
    else if (clicked)
      fill(200);
    else
      fill(100);

    rect(x, y, cellW, cellH);

    fill(0);
    textSize(min(cellW, cellH) * 0.6);
    text(myLabel, x + cellW/2, y + cellH/2);
  }

  public void setLabel(String newLabel)
  {
    myLabel = newLabel;
  }
  public void setLabel(int newLabel)
  {
    myLabel = "" + newLabel;
  }
  public boolean isFlagged()
  {
    return flagged;
  }
}
