static final int Width = 800;
static final int Height = 600;
static final int MaxValue = 256;
static final byte PixelsToMove = 3;
static final byte numberOfEnemies = 15;

boolean inGame;
byte currentSize;
MovingHandler movingHandler = new MovingHandler();
Circle me;
ArrayList<EnemyCircle> enemies;
String message;

void setup()
{
  size(800, 600);
  noStroke();
  newGame();
}

void newGame()
{
  inGame = true;
  currentSize = 10;
  me = new Circle((short)(Width / 2), (short)(Height / 2), currentSize);
  enemies = new ArrayList<EnemyCircle>();
  message = "";

  for (byte enemyIndex = 0; enemyIndex < numberOfEnemies; enemyIndex++)
  {
    EnemyCircle enemy;
    do
    {
      byte r = (byte)random(5, 20);
      short x = (short)random(r, Width - r);
      short y = (short)random(r, Height - r);
      enemy = new EnemyCircle(x, y, r);
    }
    while (me.getCollidingCircle(enemy) != null);    
    enemies.add(enemy);
  }
}

void draw()
{
  background(140, 140, 140);
  me.move();
  boolean drawMe = true;
  if (message != "")
  {
    showMessage(32, 255, 0, 0, CENTER, CENTER, Width / 2, Height / 2, message);
  }
  else
  {
    EnemyCircle enemy = me.getCollidingCircle(enemies);
    if (enemy == null)
    {
      for (byte enemyIndex = 0; enemyIndex < enemies.size(); enemyIndex++)
      {
        EnemyCircle currentEnemy = enemies.get(enemyIndex);
        currentEnemy.changeMoving();
        currentEnemy.move();
        currentEnemy.draw();
      }
    }
    else
    {
      if (me.getRadius() >= enemy.getRadius())
      {
        enemies.remove(enemy);
        me.draw();
        me.incRadius((byte)(enemy.getRadius() / 4));
        if (enemies.size() == 0)
        {
          message = "You won!";
          inGame = false;
        }
      }
      else
      {
        message = "Game over!";
        drawMe = false;
        enemy.draw();
        inGame = false;
      }
    }
    
    if (drawMe)
    {
      me.draw();
    }
  }
}

void keyPressed()
{
  movingHandler.HandleKeyPress();
}

void keyReleased()
{
  movingHandler.HandleKeyRelease();
}

void showMessage(int size, int r, int g, int b, int alignX, int alignY, int x, int y, String message)
{
  fill(r, g, b);
  textSize(size);
  textAlign(alignX, alignY);
  text(message, x, y);
}

boolean getRandomBoolean()
{
  int rnd = (int)random(0, 2);
  return rnd < 1;
}


class Point
{  
  private short x;
  private short y;
  
  public Point(short x, short y)
  {
    this.x = x;
    this.y = y;
  }
  
  public short getX()
  {
    return x;
  }
  
  public short getY()
  {
    return y;
  }

  public void setX(short value)
  {
    x = value;
  }
  
  public void setY(short value)
  {
    y = value;
  }  

  public float getDistance(Point point)
  {
    return dist(x, y, point.x, point.y);
  }
}

class Circle
{
  private Point origo;
  private byte r;
  private byte red, green, blue;
  private short moveModifierRigth = 0, moveModifierLeft = 0, moveModifierUp = 0, moveModifierDown = 0;
  
  public Circle(short x, short y, byte r)
  {
    origo = new Point(x, y);
    this.r = r;
    red = (byte)random(0, MaxValue);
    green = (byte)random(0, MaxValue);
    blue = (byte)random(0, MaxValue);
  }
  
  public short getX()
  {
    return origo.getX();
  }
  
  public short getY()
  {
    return origo.getY();
  }
  
  public Point getOrigo()
  {
    return origo;
  }
  
  public byte getRadius()
  {
    return r;
  }
  
  public void incRadius(byte dr)
  {
    r += dr;
  }
  
  public void draw()
  {
    fill(red, green, blue);
    ellipse(origo.getX(), origo.getY(), 2 * r, 2 * r);
  }
  
  public void moveUp(boolean move)
  {
    moveModifierUp = move ? (short)-PixelsToMove : 0;
  }
  
  public void moveDown(boolean move)
  {
    moveModifierDown = move ? PixelsToMove : 0;
  }
  
  public void moveRight(boolean move)
  {
    moveModifierRigth = move ? PixelsToMove : 0;
  }
  
  public void moveLeft(boolean move)
  {
    moveModifierLeft = move ? (short)-PixelsToMove : 0;
  }
  
  public void move()
  {
    origo.setX((short)(origo.getX() + moveModifierRigth + moveModifierLeft));
    if (origo.getX() - r < 0)
    {      
      origo.setX((short)(Width - r));
    }
    if (origo.getX() + r > Width)
    {      
      origo.setX(r);
    }
    origo.setY((short)(origo.getY() + moveModifierUp + moveModifierDown));
    if (origo.getY() - r < 0)
    {      
      origo.setY((short)(Height - r));
    }
    if (origo.getY() + r > Height)
    {      
      origo.setY(r);
    }
  }
  
  public EnemyCircle getCollidingCircle(ArrayList<EnemyCircle> circles)
  {
    EnemyCircle[] result = new EnemyCircle[circles.size()];
    result = circles.toArray(result);
    return getCollidingCircle(result);    
  }
  
  public EnemyCircle getCollidingCircle(EnemyCircle... circles)
  {
    for (EnemyCircle circle: circles)
    {
      if (this.equals(circle))
      {
        continue;
      }
      if (dist(getX(), getY(), circle.getX(), circle.getY()) < me.getRadius() + circle.getRadius())
      {
        return circle;
      }
    }
    
    return null;
  }
  
  public boolean equals(Circle circle)
  {
    return circle.getX() == this.getX() && circle.getY() == this.getY() && circle.getRadius() == this.getRadius();
  }
}

class EnemyCircle extends Circle
{
  private int currentCycles;
  
  public EnemyCircle(short x, short y, byte r)
  {
    super(x, y, r);
    changeMoving();
  }
  
  public void changeMoving()
  {
    if (currentCycles > 0)
    {
      currentCycles--;
    }
    else
    {
      currentCycles = (int)random(20, 100);
      changeDirection();
    }
  }
    
  private void changeDirection()
  {
    if (getRandomBoolean())
    {
      moveDown(false);
      moveUp(true);
    }
    else
    {
      moveUp(false);
      moveDown(true);
    }
    
    if (getRandomBoolean())
    {
      moveRight(false);
      moveLeft(true);
    }
    else
    {
      moveLeft(false);
      moveRight(true);
    }
  }
}

class MovingHandler
{
  public void HandleKeyPress()
  {
    switch (key)
    {
      case CODED:
        switch (keyCode)
        {
          case RIGHT:
            me.moveRight(true);
            break;
          case LEFT:
            me.moveLeft(true);
            break;
          case DOWN:
            me.moveDown(true);
            break;
          case UP:
            me.moveUp(true);
            break;
        }
        break;
      case ' ':
        if (!inGame)
        {
          newGame();
        }
      break;
    }
  }
  
  public void HandleKeyRelease()
  {
    switch (key)
    {
      case CODED:
        switch (keyCode)
        {
          case RIGHT:
            me.moveRight(false);
            break;
          case LEFT:
            me.moveLeft(false);
            break;
          case DOWN:
            me.moveDown(false);
            break;
          case UP:
            me.moveUp(false);
            break;
        }
        break;
    }
  }
}