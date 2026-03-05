import de.bezier.guido.*;
import java.util.ArrayList;

final int NUM_ROWS = 20;
final int NUM_COLS = 20;
final int NUM_MINES = 50;

MSButton[][] buttons;
ArrayList<MSButton> mines;

boolean gameOver = false;
boolean gameWon = false;

float w, h;

void setup ()
{
    size(400, 400);
    textAlign(CENTER,CENTER);

    Interactive.make(this);

    w = width/(float)NUM_COLS;
    h = height/(float)NUM_ROWS;

    buttons = new MSButton[NUM_ROWS][NUM_COLS];
    mines = new ArrayList<MSButton>();

    for (int r=0; r<NUM_ROWS; r++)
    {
        for (int c=0; c<NUM_COLS; c++)
        {
            buttons[r][c] = new MSButton(r,c);
        }
    }

    setMines();
}

void draw ()
{
    background(0);

    for (int r=0; r<NUM_ROWS; r++)
        for (int c=0; c<NUM_COLS; c++)
            buttons[r][c].draw();

    fill(255);
    textSize(30);

    if (gameOver)
        text("YOU LOSE", width/2, height/2);
    else if (gameWon)
        text("YOU WIN", width/2, height/2);
}

void setMines()
{
    while (mines.size() < NUM_MINES)
    {
        int r = (int)random(NUM_ROWS);
        int c = (int)random(NUM_COLS);

        MSButton b = buttons[r][c];

        if (!mines.contains(b))
        {
            mines.add(b);
            b.mine = true;
        }
    }
}

boolean isValid(int r,int c)
{
    if (r>=0 && r<NUM_ROWS && c>=0 && c<NUM_COLS)
        return true;
    else
        return false;
}

int countMines(int row,int col)
{
    int count=0;

    for(int dr=-1; dr<=1; dr++)
    {
        for(int dc=-1; dc<=1; dc++)
        {
            if(!(dr==0 && dc==0))
            {
                int rr=row+dr;
                int cc=col+dc;

                if(isValid(rr,cc))
                {
                    if(buttons[rr][cc].mine)
                        count++;
                }
            }
        }
    }

    return count;
}

boolean isWon()
{
    for(int r=0;r<NUM_ROWS;r++)
    {
        for(int c=0;c<NUM_COLS;c++)
        {
            if(!buttons[r][c].mine && !buttons[r][c].clicked)
                return false;
        }
    }

    return true;
}

void displayLosingMessage()
{
    gameOver=true;

    for(int i=0;i<mines.size();i++)
    {
        MSButton b=mines.get(i);
        b.clicked=true;
        b.label="X";
    }
}

void displayWinningMessage()
{
    gameWon=true;
}

public class MSButton
{
    int row,col;
    float x,y;
    boolean clicked=false;
    boolean flagged=false;
    boolean mine=false;
    String label="";

    MSButton(int r,int c)
    {
        row=r;
        col=c;

        x=col*w;
        y=row*h;

        Interactive.add(this);
    }

    void mousePressed()
    {
        if(gameOver || gameWon)
            return;

        if(mouseButton==RIGHT)
        {
            flagged=!flagged;

            if(flagged)
                label="F";
            else
                label="";

            return;
        }

        if(flagged==false && clicked==false)
        {
            clicked=true;

            if(mine)
            {
                displayLosingMessage();
                return;
            }

            int n=countMines(row,col);

            if(n>0)
            {
                label=""+n;
            }
            else
            {
                int dr=-1;
                while(dr<=1)
                {
                    int dc=-1;
                    while(dc<=1)
                    {
                        if(!(dr==0 && dc==0))
                        {
                            int rr=row+dr;
                            int cc=col+dc;

                            if(isValid(rr,cc))
                            {
                                MSButton nb=buttons[rr][cc];

                                if(nb.clicked==false && nb.flagged==false)
                                    nb.mousePressed();
                            }
                        }

                        dc++;
                    }
                    dr++;
                }
            }

            if(isWon())
                displayWinningMessage();
        }
    }

    void draw()
    {
        stroke(50);

        if(flagged)
            fill(50);
        else if(clicked && mine)
            fill(255,0,0);
        else if(clicked)
            fill(200);
        else
            fill(120);

        rect(x,y,w,h);

        fill(0);
        text(label,x+w/2,y+h/2);
    }
}


