import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;
Minim minim;

AudioSample SE;
AudioPlayer music;

int Lock=0;
int gameState=-1;
String routeState="";
String[] Branch;
PFont  mainfont;
String[] name, msg;
String[] chara;
String[] minigame;
int idx=0;
int startTime;
int a=0;
PImage stage;
boolean Displaying=false;
boolean selecting=false;
PImage left, center, right;
String[] nameReference;
int musicVolume = -20;
PImage[] img;
String[] imgReference;
PImage textBox;
int[] Temporarily = new int[1];
int hoomButton = 0;
float WheelMove;
PImage InitializeButton, homeButton, jumpButton;
int Score=0;
PImage[] minigameIMG;

void setup() {
  size(800, 450);
  mainfont  =  loadFont("MeiryoUI-Bold-48.vlw");
  textFont(mainfont);
  background(0);
  fill(255);
  textAlign(CENTER, BASELINE);
  textSize(30);
  text("ロード中...", width/2, height/2);
  textAlign(RIGHT, BASELINE);
  textSize(20);
  text("「S」キーでスクリーンショットが撮れる", width-20, height-20);
}

void  draw_logInSetup() {
  minim = new Minim(this);
  SE = minim.loadSample("sound/appear01.wav");
  SE.setGain(-20);
  music = minim.loadFile("sound/n66.mp3");

  Branch = loadStrings("Branch.csv");
  nameReference = loadStrings("name.csv");
  imgReference = loadStrings("image.txt");
  img = new PImage [imgReference.length];
  for (int  i=0; i  < imgReference.length; i++) {
    img[i] = loadImage("img/"+imgReference[i]+".png");
  }

  homeButton = loadImage("img/homeButton.png");
  InitializeButton = loadImage("img/Initialize.png");
  jumpButton = loadImage("img/jumpButton.png");
  textBox = loadImage("img/Text box.png");
  colorMode(HSB, 359, 99, 99);
  stage = loadImage("img/home.png");
}

void  draw() {
  if (gameState==-1) {
    draw_logInSetup();
    gameState=0;
  } else if (gameState==0) {
    draw_home();
  } else if (gameState==1) {
    draw_Jump();
    draw_InitializeButton();
    if (Lock>0) {
      fill(0, 0, 99);
      textSize(30);
      textAlign(LEFT, BOTTOM);
      text(str(Lock), 10, height-10);
    }
    if (Lock==9) {
      draw_BranchSaveInitialize(1);
      Lock=0;
    }
  } else if (gameState>=2) {
    draw_maingame();
  }
  if (gameState>0) {
    if (!(gameState==2&&idx<name.length&&"エンディング".equals(name[idx])==true)) {
      draw_homeButton();
    }
  }
}

void draw_home() {
  draw_stage(255);
  if (music.isPlaying()==false) {
    music.setGain(musicVolume);
    music.loop();
  }
  textSize(50);
  textAlign(LEFT, TOP);
  float sx=width/2-textWidth("start")/2;
  int y=height/4*3;
  if (sx<=mouseX&&mouseX<=sx+textWidth("start")&&y<=mouseY&&mouseY<=y+textAscent()) {
    fill(0, 0, 65);
    if (mousePressed && mouseButton == LEFT) {
      if (Displaying==false) {
        SE.trigger();
        draw_maingameSetup(0);
      }
      gameState=2;
      Displaying = true;
      startTime = millis();
    }
  } else {
    fill(0, 0, 99);
  }
  text("start", sx, y);

  int r=jumpButton.width/2;
  int cx=width-r-10;
  int cy=height/3*2;
  tint(0, 0, 99);
  if (dist(cx, cy, mouseX, mouseY)<=r) {
    tint(0, 0, 65);
    if (mousePressed && mouseButton == LEFT) {
      if (Displaying==false) {
        SE.trigger();
      }
      gameState=1;
      Displaying = true;
      selecting = true;
      Temporarily = new int [2];
      Temporarily[0]=-1;
      Temporarily[1]=-1;
    }
  }
  imageMode(CENTER);
  image(jumpButton, cx, cy, 2*r, 2*r);
}


void draw_maingameSetup(int route) {
  draw_routeChange(0, str(route), "route");
  chara = new String [3];
  for (int  i=0; i  <  chara.length; i++) {
    chara[i] = "";
  }

  SE = minim.loadSample("sound/appear02.wav");
  SE.setGain(-20);
  Score=0;
}

void draw_maingame() {
  draw_stage(255);
  draw_Characters(2);
  tint(0, 0, 99);
  if (gameState!=5) {
    imageMode(CORNER);
    image(textBox, 0, 0, width, height);
  }
  if (idx < name.length) {
    draw_game();
  }
}

void draw_game() {
  if ("選択肢".equals(name[idx])) {
    if (selecting==false&&Displaying==true) {
      draw_BranchSave();
    }
    draw_select(msg[idx], 30, height/4*3+10, 25);
  } else if ("中央大".equals(name[idx])) {
    background(0);
    fill(0, 0, 99);
    draw_msg(msg[idx], int(width-textWidth(msg[idx]))/2, height/2, width-25, height, 30);
  } else if ("ブラックイン".equals(name[idx])) {
    draw_BlackIn();
    if (selecting == false && Displaying == true) {
      idx++;
    }
  } else if ("ブラックアウト".equals(name[idx])) {
    draw_BlackOut();
    if (selecting == false && Displaying == true) {
      idx++;
    }
  } else if ("ステージ".equals(name[idx])) {
    selecting=true;
    Displaying=false;
    stage = loadImage("img/"+msg[idx]+".png");
    background(0);
    idx++;
  } else if ("キャラクター".equals(name[idx])) {
    draw_charaChange(msg[idx]);
    idx++;
  } else if ("エンド".equals(name[idx])) {
    draw_routeChange(0, msg[idx], "end");
  } else if ("ミュージック".equals(name[idx])) {
    draw_musicChange(msg[idx]);
    idx++;
  } else if ("ミニゲーム".equals(name[idx])) {
    if (int(msg[idx])==1) {
      draw_miniGame1();
    } else if (int(msg[idx])==2) {
      draw_miniGame2();
    } else if (int(msg[idx])==3) {
      draw_miniGame3();
    }
  } else if ("エンディング".equals(name[idx])) {
    background(0);
    if (Displaying==true) {
      if (selecting==false) {
        selecting=true;
        draw_endingSetup(msg[idx]);
      } else {
        draw_ending(msg);
      }
    } else {
      draw_ReHome(selecting==false);
    }
  } else if ("ルート".equals(name[idx])) {
    idx++;
  } else if ("スコア分岐".equals(name[idx])) {
    String type="route";
    if ("エンド".equals(name[idx+1])) {
      type="end";
    }
    String[] Criteria = split(msg[idx], "/");
    if (Score<=int(Criteria[0])) {
      draw_routeChange(0, msg[idx+1], type);
    } else {
      if (Criteria.length>1) {
        for (int  i=1; i  < Criteria.length; i++) {
          if (int(Criteria[i-1])<Score&&Score<=int(Criteria[i])) {
            draw_routeChange(i, msg[idx+1], type);
          }
        }
        if (int(Criteria[Criteria.length-1])<Score) {
          draw_routeChange(Criteria.length, msg[idx+1], type);
        }
      } else {
        if (int(Criteria[Criteria.length-1])<Score) {
          draw_routeChange(Criteria.length, msg[idx+1], type);
        }
      }
    }
  } else {
    textAlign(CENTER, BASELINE);
    textSize(20);
    fill(0, 0, 99);
    text(name[idx], 55, height/4*3-10);
    draw_msg(msg[idx], 30, height/4*3+10, width-60, height/4-10, 20);
  }
}

void draw_msg(String m, int x, int y, int w, int h, int F) {
  selecting=false;
  textSize(F);
  textAlign(LEFT, TOP);
  float s = 10-constrain(m.length()/10, 2, 6);
  int i = int((millis()-startTime)/(s*10));
  if ( i < m.length() && Displaying == true ) {
    text(m.substring( 0, i ), x, y, w, h);
    if (frameCount%2==0) {
      SE.trigger();
    }
  } else {
    Displaying = false;
    text(m, x, y, w, h);
  }
}

void mouseClicked() {
  if (mouseButton == LEFT) {
    if ((gameState==2) && ("エンディング".equals(name[idx])==false)) {
      if (selecting==false) {
        if (Displaying == false) {
          if (idx < msg.length-1) {
            Displaying = true;
            idx++;
            startTime = millis();
          }
          if (idx>msg.length-1) {
            idx=msg.length-1;
          }
        } else {
          if (millis()-startTime>500) {
            Displaying = false ;
          }
        }
      }
    } else if (gameState==3) {
      for (int i=2-1; 0<=i; i--) {
        for (int j=3-1; 0<=j; j--) {
          if ((266+150*i<=mouseX&&mouseX<=266+150*i+120)&&(68+83*j<=mouseY&&mouseY<=68+83*j+62)) {
            Temporarily[i+j*2] = (Temporarily[i+j*2]+1)%2;
            if (Temporarily[i+j*2]==1) {
              Temporarily[6]=i+j*2;
              startTime = millis();
            }
          }
        }
      }
    } else if (gameState==4) {
      if ((417<=mouseX&&mouseX<=442)&&(161<=mouseY&&mouseY<=186)) {
        Temporarily[0]=0;
      } else if ((448<=mouseX&&mouseX<=473)&&(165<=mouseY&&mouseY<=186)) {
        Temporarily[0]=1;
      } else if ((490<=mouseX&&mouseX<=512)&&(0<=mouseY&&mouseY<=46)) {
        Temporarily[0]=2;
      }
    }
  }
}



void draw_BlackIn() {
  background(0);
  draw_stage(a);
  if (a==0 && Displaying==true) {
    if (music.isMuted()==false) {
      music.shiftGain(musicVolume, -50, 1000);
    }
  }
  if (a<255) {
    a += 10;
    selecting = true;
    Displaying = false;
  } else {
    startTime = millis();
    selecting = false;
    Displaying = true;
    a=0;
    if (music.isMuted()==true) {
      music.unmute();
    }
    music.shiftGain(-60, musicVolume, 4000);
  }
}

void draw_BlackOut() {
  draw_stage(255);
  fill(0, 0, 0, a);
  rect(0, 0, width, height);
  if (a==0) {
    if (music.isMuted()==false) {
      music.shiftGain(musicVolume, -80, 5000);
    }
  }
  if (a<255) {
    a += 10;
    selecting = true;
    Displaying = false;
  } else {
    if (music.isMuted()==false) {
      music.mute();
    }
    startTime = millis();
    selecting = false;
    Displaying = true;
    a=0;
  }
}


void draw_stage(int alpa) {
  imageMode(CORNER);
  tint(0, 0, 99, alpa);
  image(stage, 0, 0, width, height);
}

void draw_select(String m, int sx, int y, int F) {
  selecting=true;
  Displaying=false;
  String[]  choice  =  split(m, "/");
  textAlign(LEFT, TOP);
  textSize(F);
  float[] x = new float [choice.length+1];
  x[0]=sx;
  color[] c = new color [choice.length];
  for (int i=0; i<choice.length; i++) {
    if (x[i]<=mouseX&&mouseX<=x[i]+textWidth(choice[i])&&y<=mouseY&&mouseY<=y+textAscent()) {
      c[i] = color(0, 60, 99);
      if (mousePressed && mouseButton == LEFT) {
        draw_routeChange(i, msg[idx+1], "route");
      }
    } else {
      c[i] = color(190, 55, 99);
    }
    x[i+1]=x[i]+textWidth(choice[i])+textWidth(" / ");
    fill(c[i]);
    text(choice[i], x[i], y);
    if (i < choice.length-1) {
      fill(0, 0, 99);
      text(" / ", x[i]+textWidth(choice[i]), y);
    }
  }
}

void draw_routeChange(int i, String m, String type) {
  String[]  route  =  split(m, "/");
  if (routeState.equals(type+route[i])==false) {
    idx=0;
    String[] story  =  loadStrings("story/"+type+route[i]+".txt");
    routeState = type+route[i];
    name = new String [story.length];
    msg = new String [story.length];
    for (int  j=0; j  <  story.length; j++) {
      String[]  temp  =  split(story[j], "　");
      name[j]  =  temp[0];
      if (story[j].indexOf("　") == -1) {
        msg[j]  =  "";
      } else {
        msg[j]  =  temp[1];
      }
    }
  } else {
    idx+=2;
  }
  startTime = millis();
  Displaying = true;
}

void draw_Characters(int S) {
  float[] y = new float [chara.length];
  float w = 70;
  for (int i=0; i<chara.length; i++) {
    y[i]=0;
  }
  String TalkingChara = "";
  for (int i=0; i<nameReference.length; i++) {
    String[] Corresponding = split(nameReference[i], ",");
    if (Corresponding[0].equals(name[idx])) {
      TalkingChara = Corresponding[1];
    }
  }
  if ((millis()-startTime <= 0.5*1000)&&(Displaying==true)) {
    for (int i=0; i<chara.length; i++) {
      String[] c = split(chara[i], "_");
      if (c[0].equals(TalkingChara)) {
        y[i]=-sin(radians(map(millis()-startTime, 0, 0.5*1000, 0, 720)))*5;
      }
    }
  }
  if ("".equals(chara[0])==false && "".equals(chara[1])==false && "".equals(chara[2])==false) {
    if (center!=null) {
      w = center.width/S + 14;
    } else {
      w+=200;
    }
  }
  tint(0, 0, 99);
  imageMode(CORNER);
  if ("".equals(chara[0])==false && left!=null) {
    image(left, width/2-left.width/S-w/2, y[0], left.width/S, left.height/S);
  }
  if ("".equals(chara[2])==false && right!=null) {
    image(right, width/2+w/2, y[2], right.width/S, right.height/S);
  }
  imageMode(CENTER);
  if ("".equals(chara[1])==false && center!=null) {
    image(center, width/2, y[1]+center.height/(S*2), center.width/S, center.height/S);
  }
}

void draw_charaChange(String m) {
  chara  =  split(m, "/");
  int[] existence = new int [3];
  for (int  i=0; i < existence.length; i++) {
    existence[i]=0;
  }
  for (int  i=0; i < imgReference.length; i++) {
    if (chara[0].equals(imgReference[i])) {
      left = img[i];
      existence[0]++;
    }
    if (chara[1].equals(imgReference[i])) {
      center = img[i];
      existence[1]++;
    }
    if (chara[2].equals(imgReference[i])) {
      right = img[i];
      existence[2]++;
    }
  }

  if (existence[0]==0) {
    left = null;
  }
  if (existence[1]==0) {
    center = null;
  }
  if (existence[2]==0) {
    right = null;
  }

  startTime = millis();
  Displaying = true;
}

void draw_musicChange(String m) {
  music.close();
  music = minim.loadFile("sound/"+m+".mp3");
  music.shiftGain(-50, musicVolume, 1000);
  music.loop();
}

void draw_endingSetup(String m) {
  music.close();
  music = minim.loadFile("sound/"+m+".mp3");
  music.shiftGain(-50, musicVolume, 3000);
  msg = loadStrings("ending.txt");
}

void draw_ending(String[] m) {
  fill(0, 0, 99);
  textSize(30);
  textAlign(LEFT, TOP);
  float h = textAscent() + textDescent() + 10;
  music.play();
  int musicLength=music.length();
  if (millis()-startTime <= musicLength) {
    for (int i=0; i<6; i++) {
      int s = musicLength/6;
      if ((s*i < millis()-startTime) && (millis()-startTime <= s*(i+1))) {
        if ((s*i < millis()-startTime) && (millis()-startTime <= s*i+s/3)) {
          a = int(map(millis()-startTime, s*i, s*i+s/3, 0, 254));
        } else if ((s*i+s/3 < millis()-startTime) && (millis()-startTime <= s*i+s/3*2)) {
          a = 255;
        } else {
          a = 255-int(map(millis()-startTime, s*i+s/3*2, s*(i+1), 0, 255));
        }
        imageMode(CENTER);
        PImage IMG = img[(5*i)%img.length];
        float S = 3;
        float w = 30;
        if (img[0].height>IMG.height) {
          S = constrain(S/img[0].height*IMG.height, 1, S);
        }
        if (width<width/3*2+w+IMG.width/S) {
          w=w+width-(width/3*2+w+IMG.width/S+10);
        }
        tint(0, 0, 99, a);
        float IY=height/2+20;
        if (IMG.height/S-20>height) {
          IY = height/(S*3+1)+IMG.height/(S*2);
        }
        image(IMG, width/3*2+w+IMG.width/(S*2), IY, IMG.width/S, IMG.height/S);
      }
    }
    float y = map(millis()-startTime, 0, musicLength, height+10, -h*m.length);
    for (int  i=0; i < m.length; i++) {
      text(m[i], 20, y+h*i);
    }
  } else {
    Displaying = false;
    selecting = false;
    a = 0;
  }
}

void draw_miniGame1() {
  gameState=3;
  if (selecting==false) {
    Temporarily = new int [7];
    for (int  i=0; i  < Temporarily.length; i++) {
      Temporarily[i]=0;
    }
    Temporarily[6]=-1;
    minigame = loadStrings("story/miniGame1.txt");
  }
  selecting=true;
  Displaying=false;
  int[] open = new int[6];
  for (int  i=0; i  < open.length; i++) {
    open[i]=Temporarily[i];
  }
  int comment = Temporarily[6];
  PImage[] drawer = new PImage[6];
  for (int  i=0; i < imgReference.length; i++) {
    String[] temp = split(imgReference[i], "/");
    if ("drawer".equals(temp[0])) {
      drawer[int(temp[1])] = img[i];
    }
  }
  for (int i=2-1; 0<=i; i--) {
    for (int j=3-1; 0<=j; j--) {
      if (open[i+j*2] == 1 && drawer[i+j*2]!=null) {
        imageMode(CENTER);
        tint(0, 0, 99);
        image(drawer[i+j*2], 323+150*i, 68+83*j+drawer[i+j*2].height/(2*2), drawer[i+j*2].width/2, drawer[i+j*2].height/2);
      }
    }
  }
  if ((0<=comment&&comment<3)||(3<comment&&comment<6)) {
    String[] M = split(minigame[comment], "　");
    textAlign(CENTER, BASELINE);
    textSize(20);
    fill(0, 0, 99);
    text(M[0], 55, height/4*3-10);
    textAlign(LEFT, TOP);
    float s = 10-constrain(M[1].length()/10, 2, 6);
    int i = int((millis()-startTime)/(s*10));
    if ( i < M[1].length()) {
      text(M[1].substring( 0, i ), 30, height/4*3+10, width-60, height/4-10);
      if (frameCount%2==0) {
        SE.trigger();
      }
    } else {
      text(M[1], 30, height/4*3+10, width-60, height/4-10);
    }
  } else if (Temporarily[6]==-1) {
    textAlign(LEFT, TOP);
    textSize(25);
    fill(190, 55, 99);
    text("引き出しを選んでね", 30, height/4*3+10, width-60, height/4-10);
  }
  if (open[3]==1) {
    startTime = millis();
    Displaying = true;
    selecting = false;
    gameState=2;
    idx++;
  }
  for (int  i=0; i  < open.length; i++) {
    Temporarily[i]=open[i];
  }
}

void draw_miniGame2() {
  gameState=4;
  if (selecting==false) {
    selecting=true;
    Temporarily = new int [1];
    for (int  i=0; i  < Temporarily.length; i++) {
      Temporarily[i]=0;
    }
    Temporarily[0]=-1;
    minigame=null;
    minigame = new String [3];
    minigame[0]="青と白の箱";
    minigame[1]="青と赤の箱";
    minigame[2]="ラムネ";
  }
  int select = Temporarily[0];
  String m = "薬を選んでね";
  if ((417<=mouseX&&mouseX<=442)&&(161<=mouseY&&mouseY<=186)) {
    m=minigame[0];
  } else if ((448<=mouseX&&mouseX<=473)&&(165<=mouseY&&mouseY<=186)) {
    m=minigame[1];
  } else if ((490<=mouseX&&mouseX<=512)&&(0<=mouseY&&mouseY<=46)) {
    m=minigame[2];
  }
  textAlign(LEFT, TOP);
  textSize(25);
  fill(190, 55, 99);
  text(m, 30, height/4*3+10, width-60, height/4-10);
  if (select >= 0) {
    if (select == 2) {
      msg[idx+1]="「うん！これかな！ラムネっておくすりみたいだし、あまくておいしいし！」";
      Score-=2;
    }
    if (select == 0) {
      Score--;
    }
    if (select == 1) {
      Score++;
    }
    startTime = millis();
    Displaying = true;
    selecting = false;
    gameState=2;
    idx++;
  }
}

void draw_miniGame3() {
  gameState=5;
  if (selecting==false) {
    selecting=true;
    draw_charaChange("//");
    stage = loadImage("img/mg fish/Pond bottom.png");
    minigameIMG = new PImage [4];
    minigameIMG[0] = loadImage("img/mg fish/Water surface.png");
    minigameIMG[1] = loadImage("img/mg fish/feed.png");
    minigameIMG[2] = loadImage("img/mg fish/Ficon.png");
    minigameIMG[3] = loadImage("img/mg fish/fish.png");
    Temporarily = new int [17];
    for (int  i=0; i  < Temporarily.length; i++) {
      Temporarily[i]=0;
    }
    Temporarily[0]=5;
  }


  int feed = Temporarily[0];
  int fish = Temporarily[1];
  int feedExist = Temporarily[2];
  int Fx = Temporarily[3];
  int Fy = Temporarily[4];
  int[] v = new int[3];
  int[] c = new int [3];
  int[] hant = new int [3];
  PImage F = minigameIMG[3];
  int[] y = new int [3];

  for (int  i=0; i  < hant.length; i++) {
    hant[i] = Temporarily[i+5];
  }
  for (int  i=0; i  < y.length; i++) {
    y[i] = Temporarily[i+8];
  }
  for (int  i=0; i  < v.length; i++) {
    v[i] = Temporarily[i+11];
  }
  for (int  i=0; i  < c.length; i++) {
    c[i] = Temporarily[i+14];
  }


  imageMode(CENTER);
  tint(0, 0, 50);
  if (mousePressed && mouseButton == RIGHT) {
    if (feedExist==0) {
      feedExist=1;
      feed--;
      Fx=mouseX;
      Fy=mouseY;
      for (int  i=0; i  < 3; i++) {
        v[i]=int(random(5, 30));
        c[i]=int(random(0, 359));
      }
      for (int  i=0; i  < y.length; i++) {
        y[i] = int(dist(0, 0, Fx, Fy)+F.height);
      }
    }
  }

  if (feedExist==1||feedExist==-1) {

    for (int  i=0; i  < 3; i++) {
      translate(Fx, Fy);
      rotate(radians(c[i]));
      y[i]-=v[i];
      imageMode(CENTER);
      if (hant[i]==0) {
        float X= (mouseX-Fx)*cos(c[i]) + (mouseY-Fy)*sin(c[i]);
        float Y= -(mouseX-Fx)*cos(c[i]) + (mouseY-Fy)*cos(c[i]);
        float rx=-F.width/2+50;
        float ry1=y[i]-F.height/2+60;
        float ry2=y[i]+F.height/2;
        if ((rx<X&&X<-rx)&&(ry1<Y&&Y<ry2)) {
          if (mousePressed&&mouseButton==LEFT) {
            hant[i]=1;
            fish++;
          }
        }
      }
      if (hant[i]==0) {
        image(F, 0, y[i]);
      }
      if (y[i]<=0) {
        v[i]=5;
      }
      if (feedExist==0) {
        if (y[0]<0&&y[1]<0&&y[2]<0) {
          feedExist=-1;
          for (int  j=0; j  < 3; j++) {
            v[j]=int(random(8, 20));
            c[j]+=int(random(0, 40));
          }
        }
      }
      int tmp=int(dist(0, 0, Fx, Fy)+F.height);
      if (y[0]<=-tmp&&y[1]<=-tmp&&y[2]<=-tmp) {
        feedExist=0;
      }
      resetMatrix();
    }
  }

  textSize(20);
  fill(0, 0, 99);
  textAlign(LEFT, CENTER);
  imageMode(CENTER);
  tint(0, 0, 99);
  text(";", width-45, 50);
  text(";", width-45, 50+minigameIMG[1].height/2+minigameIMG[2].height/2+5);

  textAlign(CENTER, CENTER);
  text(str(feed), width-25, 50);
  image(minigameIMG[1], width-50-minigameIMG[1].width/2, 50);
  text(str(fish), width-25, 50+minigameIMG[1].height/2+minigameIMG[2].height/2+5);
  image(minigameIMG[2], width-50-minigameIMG[2].width/2, 50+minigameIMG[1].height/2+minigameIMG[2].height/2+5);


  imageMode(CORNER);
  tint(0, 0, 99);
  image(minigameIMG[0], 0, 0, width, height);
  textAlign(LEFT, TOP);
  textSize(25);
  fill(190, 55, 99);
  text("魚を3匹捕まえよう！", 50, height/4*3+10, width-60, height/4-10);
  float temp=textAscent()+textDescent();
  textSize(20);
  text("右クリックでエサを落として、左クリックで魚を捕まえられるよ", 50, height/4*3+10+temp, width-60, height/4-10);

  if (fish==3) {
    Score=3;
    startTime = millis();
    Displaying = true;
    selecting = false;
    gameState=2;
    idx++;
  } else if (feed==0) {
    Score=fish;
    startTime = millis();
    Displaying = true;
    selecting = false;
    gameState=2;
    idx++;
  }
  Temporarily[0]=feed;
  Temporarily[1]=fish;
  Temporarily[2]=feedExist;
  Temporarily[3]=Fx;
  Temporarily[4]=Fy;

  for (int  i=0; i  < hant.length; i++) {
    Temporarily[i+5]=hant[i];
  }
  for (int  i=0; i  < y.length; i++) {
    Temporarily[i+8]=y[i];
  }
  for (int  i=0; i  < v.length; i++) {
    Temporarily[i+11]=v[i];
  }
  for (int  i=0; i  < c.length; i++) {
    Temporarily[i+14]=c[i];
  }
}



void draw_Jump() {
  selecting=true;
  int State = Temporarily[0];
  int selectNumber = Temporarily[1];

  if (State==-1) {
    draw_BlackOut();
    if (selecting == false && Displaying == true) {
      State=0;
      music.unmute();
      draw_musicChange("o13");
    }
  } else {
    background(0);

    int[] route = new int [Branch.length];
    int[]ID = new int [Branch.length];
    int[]clear = new int [Branch.length];

    String[] Stage = new String [Branch.length];
    String[] Music = new String [Branch.length];
    String[] C = new String [Branch.length];
    String[] m = new String [Branch.length];

    for (int  i=0; i  < Branch.length; i++) {
      String[] temp = split(Branch[i], ",");
      if (Branch[i].indexOf(",")!=-1) {
        route[i]=int(temp[0]);
        ID[i]=int(temp[1]);
        Stage[i] = temp[2];
        Music[i] = temp[3];
        C[i] = temp[4];
        m[i]=temp[5];
        clear[i]=int(temp[6]);
      }
    }

    textSize(30);
    textAlign(CENTER, TOP);
    int V = 10;
    float y = 20;
    WheelMove = constrain(WheelMove, (-height+y+(textAscent()+textDescent()+30))/V, ((Branch.length-1)*(textAscent()+textDescent()+30)+y)/V);
    int barX=width-width/8;
    int barW=20;
    int barH=30;
    int barWH=50;
    float barY = map(y - WheelMove*V, -(Branch.length-1)*(textAscent()+textDescent()+30), height-(textAscent()+textDescent()+30), barWH, height-barWH-barH);
    y = y - WheelMove*V;
    int x=width/2;
    stroke(0, 0, 99);
    fill(0, 0, 99, 100);
    rect(barX, barWH, barW, height-barWH*2);
    fill(0, 0, 99);
    noStroke();
    rect(barX, barY, barW, barH);
    text("行きたい時点を選んでね", x, y);
    y += (textAscent()+textDescent()+10);
    textSize(20);
    text("マウスホイールでスクロールできるよ", x, y);
    textSize(26);

    for (int  i=0; i  < Branch.length; i++) {

      y += (textAscent()+textDescent()+30);

      if (State==0) {
        fill(190, 55, 99);
        if (clear[i]==1) {
          if (x-textWidth(m[i])/2<=mouseX&&mouseX<=x+textWidth(m[i])/2&&y<=mouseY&&mouseY<=y+textAscent()) {
            fill(0, 60, 99);
            if (mousePressed && mouseButton == LEFT) {
              SE.trigger();
              startTime=millis();
              State=1;
              selectNumber=i;
            }
          }
        } else {
          fill(0, 0, 65);
        }
        text(m[i], x, y);
      }
    }
    if (State>=1) {
      if (State==1) {
        draw_maingameSetup(int(route[selectNumber]));
        draw_charaChange(C[selectNumber]);
        stage = loadImage("img/"+Stage[selectNumber]+".png");
        idx=ID[selectNumber];
        State=2;
      }

      draw_BlackIn();
      if (selecting == false && Displaying == true) {
        gameState=2;
        draw_musicChange(Music[selectNumber]);
      }
    }
  }

  Temporarily[0] = State;
  Temporarily[1] = selectNumber;
}

void draw_homeButton() {
  int x=10;
  int y=10;
  int w=homeButton.width;
  int h=homeButton.height;

  tint(0, 0, 99);
  if (x<=mouseX&&mouseX<=x+w&&y<=mouseY&&mouseY<=y+h) {
    tint(0, 0, 65);
    if (mousePressed && mouseButton == LEFT) {
      hoomButton=1;
    }
  }
  imageMode(CORNER);
  image(homeButton, x, y, w, h);
  if (hoomButton>0) {
    draw_ReHome(hoomButton==1);
    if (hoomButton>0) {
      hoomButton=2;
    }
  }
}

void draw_ReHome(boolean JustStarting) {
  if (JustStarting==true) {
    stage = loadImage("img/home.png");
    draw_musicChange("n66");
    music.mute();
    SE.close();
    SE = minim.loadSample("sound/appear01.wav");
    SE.setGain(-20);
  }
  selecting = true;
  draw_BlackIn();
  if (selecting == false && Displaying == true) {
    if (chara!=null) {
      for (int  i=0; i  <  chara.length; i++) {
        if (chara[i].equals("")==false) {
          chara[i] = "";
        }
      }
    }
    gameState=0;
    Displaying=false;
    selecting=false;
    hoomButton=0;
    idx=0;
  }
}


void draw_BranchSave() {
  int[]ID = new int [Branch.length];
  int[]clear = new int [Branch.length];
  String[] m = new String [Branch.length];

  for (int  i=0; i  < Branch.length; i++) {
    String[] temp = split(Branch[i], ",");
    ID[i]=int(temp[1]);
    m[i]=temp[5];
    clear[i]=int(temp[6]);
    
    if (idx==ID[i]&&m[i].equals(msg[idx])) {
      if (clear[i]==0) {
        Branch[i]="";
        for (int j=0; j < temp.length-1; j++) {
          Branch[i]+=temp[j]+",";
        }
        Branch[i]+="1";
      }
      saveStrings("data/Branch.csv", Branch);
      Branch = loadStrings("Branch.csv");
      selecting=true;
    }
  }
}


void draw_BranchSaveInitialize(int save) {
  int[]clear = new int [Branch.length];
  for (int  i=0; i  < Branch.length; i++) {
    String[] temp = split(Branch[i], ",");
    clear[i]=int(temp[6]);

    if (clear[i]==(save+1)%2) {
      Branch[i]="";
      for (int j=0; j < temp.length-1; j++) {
        Branch[i]+=temp[j]+",";
      }
      Branch[i]+=str(save);
    }
    saveStrings("data/Branch.csv", Branch);
    Branch = loadStrings("Branch.csv");
    selecting=true;
  }
}

void draw_InitializeButton() {
  int w=InitializeButton.width;
  int h=InitializeButton.height;
  int x=width-10-w;
  int y=height-10-h;

  tint(0, 0, 99);
  if (x<=mouseX&&mouseX<=x+w&&y<=mouseY&&mouseY<=y+h) {
    tint(0, 0, 65);
    if (mousePressed && mouseButton == LEFT) {
      draw_BranchSaveInitialize(0);
      selecting=false;
    }
  }
  imageMode(CORNER);
  image(InitializeButton, x, y, w, h);
}

void keyTyped() {
  if (key=='s'||key=='S') {
    String ScreenShotName = year()+nf(month(), 2)+nf(day(), 2)+"_"+nf(second(), 2);
    saveFrame("ScreenShot"+"/"+ScreenShotName+".png");
  }
  if (gameState==1) {
    int temp=0;
    if (Lock==1) {
      if (temp==0&&(key=='h'||key=='H')) {
        Lock++;
        temp++;
      } else {
        Lock=0;
      }
    }
    if (temp==0&&(Lock==2||Lock==4)) {
      if (key=='o'||key=='O') {
        Lock++;
        temp++;
      } else {
        Lock=0;
      }
    }
    if (temp==0&&(key=='l'||key=='L')) {
      if (Lock==5) {
        Lock++;
        temp++;
      } else {
        Lock=0;
      }
    }
    if (temp==0&&(key=='a'||key=='A')) {
      if (Lock==6) {
        Lock++;
        temp++;
      } else {
        Lock=0;
      }
    }
    if (temp==0&&(key=='e'||key=='E')) {
      if (Lock==8) {
        Lock++;
        temp++;
      } else {
        Lock=0;
      }
    }
    if (temp==0&&(key=='t'||key=='T')) {
      if (Lock==7) {
        Lock++;
        temp++;
      } else {
        Lock=0;
      }
    }
    if (temp==0&&(Lock==0||Lock==3)) {
      if (key=='c'||key=='C') {
        Lock++;
        temp++;
      } else {
        Lock=0;
      }
    }
  }
}

void mouseWheel(MouseEvent move ) {
  if (gameState==1) {
    WheelMove += move.getAmount();
  }
}

void stop() {
  SE.close();
  music.close();
  minim.stop();
  super.stop();
}
