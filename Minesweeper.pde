import de.bezier.guido.*;
import java.util.ArrayList;

int NUM_ROWS = 5;
int NUM_COLS = 5;

private MSButton[][] buttons;
private ArrayList<MSButton> mines = new ArrayList<MSButton>();

boolean gameOver = false;
boolean gameWon = false;

void setup ()
{
    size(450, 450);
    textAlign(CENTER, CENTER);
    textSize(20);
    
    Interactive.make(this);
    
    buttons = new MSButton[NUM_ROWS][NUM_COLS];
    
    for (int r = 0; r < NUM_ROWS; r++)
        for (int c = 0; c < NUM_COLS; c++)
            buttons[r][c] = new MSButton(r, c);
    
    setMines();
}

public void setMines()
{
    while (mines.size() < 5)
    {
        int r = (int)(Math.random() * NUM_ROWS);
        int c = (int)(Math.random() * NUM_COLS);
        
        if (!mines.contains(buttons[r][c]))
            mines.add(buttons[r][c]);
    }
}

public void draw ()
{
    background(30, 40, 70);
    
    if (isWon() == true && gameOver == false)
    {
        gameWon = true;
        displayWinningMessage();
    }
}

public boolean isWon()
{
    for (int r = 0; r < NUM_ROWS; r++)
    {
        for (int c = 0; c < NUM_COLS; c++)
        {
            if (!mines.contains(buttons[r][c]) && buttons[r][c].revealed == false)
                return false;
        }
    }
    return true;
}

public void displayLosingMessage()
{
    gameOver = true;
    
    for (int i = 0; i < mines.size(); i++)
    {
        mines.get(i).revealed = true;
        mines.get(i).setLabel("X");
    }
    
    fill(255,220,220);
    textSize(36);
    text("YOU LOSE", width/2, height/2);
}

public void displayWinningMessage()
{
    fill(220,255,220);
    textSize(36);
    text("YOU WIN", width/2, height/2);
}

public boolean isValid(int r, int c)
{
    if (r >= 0 && r < NUM_ROWS && c >= 0 && c < NUM_COLS)
        return true;
    return false;
}

public int countMines(int row, int col)
{
    int nearbyBombs = 0;
    
    for (int i = row - 1; i < row + 2; i++)
    {
        for (int k = col - 1; k < col + 2; k++)
        {
            if (isValid(i, k))
            {
                if (mines.contains(buttons[i][k]))
                    nearbyBombs++;
            }
        }
    }
    
    if (mines.contains(buttons[row][col]))
        nearbyBombs--;
    
    return nearbyBombs;
}

public class MSButton
{
    private int myRow, myCol;
    private float x, y, boxW, boxH;
    boolean revealed, marked;
    private String cellText;
    
    public MSButton(int row, int col)
    {
        boxW = 450.0 / NUM_COLS;
        boxH = 450.0 / NUM_ROWS;
        myRow = row;
        myCol = col;
        x = myCol * boxW;
        y = myRow * boxH;
        cellText = "";
        marked = false;
        revealed = false;
        Interactive.add(this);
    }

    public void mousePressed()
    {
        if (gameOver || gameWon)
            return;
        
        if (mouseButton == RIGHT)
        {
            marked = !marked;
            
            if (marked)
                cellText = "F";
            else
                cellText = "";
        }
        else
        {
            if (marked == false)
            {
                revealed = true;
                
                if (mines.contains(this))
                {
                    displayLosingMessage();
                }
                else if (countMines(myRow, myCol) > 0)
                {
                    setLabel(countMines(myRow, myCol));
                }
            }
        }
    }

    public void draw()
    {
        stroke(255);
        strokeWeight(2);
        
        if (marked)
            fill(255,215,0);
        else if (revealed && mines.contains(this))
            fill(220,70,70);
        else if (revealed)
            fill(180,220,255);
        else
            fill(130,160,210);

        rect(x, y, boxW, boxH);
        
        fill(20);
        textSize(24);
        text(cellText, x + boxW/2, y + boxH/2);
    }

    public void setLabel(String newLabel)
    {
        cellText = newLabel;
    }

    public void setLabel(int newLabel)
    {
        cellText = "" + newLabel;
    }

    public boolean isFlagged()
    {
        return marked;
    }
}
