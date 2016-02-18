import generativedesign.*;
import processing.pdf.*;
import java.util.Calendar;
import org.atilika.kuromoji.Token;
import org.atilika.kuromoji.Tokenizer;
import java.util.*;

/* KEYS
 * r             : reset positions
 * s             : save png
 * p             : save pdf
 * t             : training data draw
 * e             : extraction words draw
 * d             : dictionary words ranking draw
 * UP            : data page up
 * DOWN          : data page down
 */
 
boolean savePDF = false;
boolean dataDraw = false;
boolean extractionDraw = false;
boolean rankingDraw = false;


float test_Accuracy = 0;
int test_N = 11842;  //  Max:11842

String[] searchWords = new String[100];
int      searchWords_N = 0;
String   searchSentence = "明日には心配事が多い";
String[] searchSentenceALL = new String[51];
int      searchWordsPN = 0;
int      searchWordsExPN = 0;

Tokenizer tokenizer = Tokenizer.builder().build();
PrintWriter writer1;
PrintWriter writer2;
PrintWriter writer3;

int MAX_LINE = 550000;
int MAX_CUE = 7;

int dialogue_LINE = 12000;
int dialogue_CUE = 7;

int reply_LINE = 0;
int reply_CUE = 3;
int reply_dict_LINE = 0;

// 行データ格納文字列
String[] datalines;
String[] datalines_Test;

// データ配列
String[][] dialogueValue = new String[MAX_LINE][MAX_CUE];
String[][] dialogue = new String[dialogue_LINE][dialogue_CUE];
String[][] reply = new String[MAX_LINE][MAX_CUE];
String[][] reply_dict = new String[MAX_LINE][MAX_CUE];
String[][] test50 = new String[50][dialogue_CUE];
int[] dialogueRandomLine = new int[test_N]; 
  
int dialogueValue_LINE = 0;
int wordsUpDown=0;

float P_alpha = 0.30;
float P_beta  = 0.10;
float N_alpha = -0.30;
float N_beta  = -0.10;


// Visualize
String[][] factorWords = new String[1000][3];  // N, word
int factorWords_LINE = 0;

// an array for the nodes
Node[] nodes = new Node[1000];
// an array for the springs
Spring[] springs = new Spring[0];

// dragged node
Node selectedNode = null;

float nodeDiameter = 16;

void setup() {
  // ファイル読み込み
  datalines = loadStrings("Dialogue.csv");
  datalines_Test = loadStrings("test500.csv");
  
  // ファイルが開けた場合
  if(datalines != null && datalines_Test != null) {
    for(int i = 0; i < datalines.length; i ++) {
      // 空白行でないかを確認
      if(datalines[i].length() != 0) {
        // 一行読み取ってカンマ区切りで格納
        String[] values = datalines[i].split("," , -1);
        // 列の数だけ読み取り
        for(int j = 0; j < dialogue_CUE; j ++) {
          if(values[j] != null && values[j].length() != 0) {
            dialogue[i][j] = values[j];
              // コンソール表示用
//              print(dialogue[i][j] + "\t");
          }
        }
        // コンソール表示用
//        print("\n");
      }
    }
    
    for(int i = 0; i < datalines_Test.length; i ++) {
      // 空白行でないかを確認
      if(datalines_Test[i].length() != 0) {
        // 一行読み取ってカンマ区切りで格納
        String[] values = datalines_Test[i].split("," , -1);
        // 列の数だけ読み取り
        for(int j = 0; j < dialogue_CUE; j ++) {
          if(values[j] != null && values[j].length() != 0) {
            test50[i][j] = values[j];
              // コンソール表示用
//              print(test50[i][j] + "\t");
          }
        }
        // コンソール表示用
//        print("\n");
      }
    }
  }
  
  
  boolean num[] = new boolean[datalines.length];  //重複判定用
  for (int i = 0; i < test_N; i++){
    num[i] = false;
  }
  for (int i = 0; i < test_N;) {
    int ran = floor(random(1, datalines.length + 1));
    if(num[ran-1] == false){
      dialogueRandomLine[i] = ran;
      num[ran-1] = true;
      i++;
    }
  }
  
//  dialogueValue
  for (int I = 0; I < test_N; I++) {
    int i = dialogueRandomLine[I] - 1;
    dialogueValue[dialogueValue_LINE][0] = dialogue[i][2];
    dialogueValue[dialogueValue_LINE][1] = dialogue[i][3];
    dialogueValue[dialogueValue_LINE][2] = dialogue[i][6];
    
    if (dialogue[i][3] != null && dialogue[i][6] != null) {
      String[] Phrase = dialogue[i][3].split("/", 0);
      
      if (dialogue[i][6] != null) {
        String[] Word_P = dialogue[i][4].split("/", 0);
        String[] Word_N = dialogue[i][5].split("/", 0);
        for (int j = 0 ; j < Phrase.length ; j++){
          for (int k = 0 ; k < Word_P.length ; k++){
            if (Phrase[j].matches(".*" + Word_P[k] + ".*")) {
              dialogueValue[dialogueValue_LINE][3] = Word_P[k];
              dialogueValue[dialogueValue_LINE][4] = "p";
              
              if (j > 0 && Phrase[j-1] != null) {
                dialogueValue[dialogueValue_LINE][5] = Phrase[j-1] + "/" + Phrase[j];
                if (dialogue[i][6].equals("p")) {
                  dialogueValue[dialogueValue_LINE][6] = Float.toString(P_alpha);
                } else if (dialogue[i][6].equals("n")) {
                  dialogueValue[dialogueValue_LINE][6] = Float.toString(N_alpha);
                }
                dialogueValue_LINE++;
              }
              if (j > 1 && Phrase[j-2] != null) {
               dialogueValue[dialogueValue_LINE][5] = Phrase[j-2] + "/" + Phrase[j];
                if (dialogue[i][6].equals("p")) {
                  dialogueValue[dialogueValue_LINE][6] = Float.toString(P_beta);
                } else if (dialogue[i][6].equals("n")) {
                  dialogueValue[dialogueValue_LINE][6] = Float.toString(N_beta);
                }
                dialogueValue_LINE++;
              }
              if (j+1 < Phrase.length && Phrase[j+1] != null) {
                  dialogueValue[dialogueValue_LINE][5] = Phrase[j] + "/" + Phrase[j+1];
                if (dialogue[i][6].equals("p")) {
                  dialogueValue[dialogueValue_LINE][6] = Float.toString(P_alpha);
                } else if (dialogue[i][6].equals("n")) {
                  dialogueValue[dialogueValue_LINE][6] = Float.toString(N_alpha);
                }
                dialogueValue_LINE++;
              }
              if (j+2 < Phrase.length && Phrase[j+2] != null) {
                dialogueValue[dialogueValue_LINE][5] = Phrase[j] + "/" + Phrase[j+2];
                if (dialogue[i][6].equals("p")) {
                  dialogueValue[dialogueValue_LINE][6] = Float.toString(P_beta);
                } else if (dialogue[i][6].equals("n")) {
                  dialogueValue[dialogueValue_LINE][6] = Float.toString(N_beta);
                }
                dialogueValue_LINE++;
              }
            }
          }
          
          for (int k = 0 ; k < Word_N.length ; k++){
            if (Phrase[j].matches(".*" + Word_N[k] + ".*")) {
              dialogueValue[dialogueValue_LINE][3] = Word_N[k];
              dialogueValue[dialogueValue_LINE][4] = "n";
              
              if (j > 0 && Phrase[j-1] != null) {
                dialogueValue[dialogueValue_LINE][5] = Phrase[j-1] + "/" + Phrase[j];
                if (dialogue[i][6].equals("p")) {
                  dialogueValue[dialogueValue_LINE][6] = Float.toString(P_alpha);
                } else if (dialogue[i][6].equals("n")) {
                  dialogueValue[dialogueValue_LINE][6] = Float.toString(N_alpha);
                }
                dialogueValue_LINE++;
              }
              if (j > 1 && Phrase[j-2] != null) {
               dialogueValue[dialogueValue_LINE][5] = Phrase[j-2] + "/" + Phrase[j];
                if (dialogue[i][6].equals("p")) {
                  dialogueValue[dialogueValue_LINE][6] = Float.toString(P_beta);
                } else if (dialogue[i][6].equals("n")) {
                  dialogueValue[dialogueValue_LINE][6] = Float.toString(N_beta);
                }
                dialogueValue_LINE++;
              }
              if (j+1 < Phrase.length && Phrase[j+1] != null) {
                  dialogueValue[dialogueValue_LINE][5] = Phrase[j] + "/" + Phrase[j+1];
                if (dialogue[i][6].equals("p")) {
                  dialogueValue[dialogueValue_LINE][6] = Float.toString(P_alpha);
                } else if (dialogue[i][6].equals("n")) {
                  dialogueValue[dialogueValue_LINE][6] = Float.toString(N_alpha);
                }
                dialogueValue_LINE++;
              }
              if (j+2 < Phrase.length-1 && Phrase[j+2] != null) {
                dialogueValue[dialogueValue_LINE][5] = Phrase[j] + "/" + Phrase[j+2];
                if (dialogue[i][6].equals("p")) {
                  dialogueValue[dialogueValue_LINE][6] = Float.toString(P_beta);
                } else if (dialogue[i][6].equals("n")) {
                  dialogueValue[dialogueValue_LINE][6] = Float.toString(N_beta);
                }
                dialogueValue_LINE++;
              }
            }
          }
        }
      }
    }
  }
  
  searchSentenceALL[50] = searchSentence;
  for (int i = 0; i < 50; i++) {
    searchSentenceALL[i] = test50[i][2];
  }
  
  for (int I = 0; I < 51; I++) {
    if (searchSentenceALL[I] != null ) {
      List<Token> tokens = tokenizer.tokenize(searchSentenceALL[I]);
    
      for (Token token : tokens) {
        String temp_token = token.getBaseForm();
        if ((token.getPartOfSpeech().matches(".*" + "助" + ".*")) || (token.getPartOfSpeech().matches(".*" + "接頭詞" + ".*")) || (token.getPartOfSpeech().matches(".*" + "非自立" + ".*"))) {
  
        } else if ( (token.getPartOfSpeech().matches(".*" + "名詞" + ".*")) || (token.getPartOfSpeech().matches(".*" + "動詞" + ".*")) || (token.getPartOfSpeech().matches(".*" + "形容詞" + ".*")) ){
          if (temp_token == null) {
            temp_token =  token.getSurfaceForm();
          }
          searchWords[searchWords_N] = temp_token;
          searchWords_N++;
        }
        if ( token.getPartOfSpeech().equals("助動詞,*,*,*") && (temp_token.equals("ない")) ) {
          searchWords[searchWords_N-1] += "#" + temp_token;
        } else if ( token.getPartOfSpeech().equals("助動詞,*,*,*") && (temp_token.equals("ん")) ) {
          searchWords[searchWords_N-1] += "#" + temp_token;
        }
      }
    }

    for (int i = 0; i < searchWords_N; i++ ) {
      boolean Find = false;
      float wordPoint = 0;
      for (int j = 0; j < dialogueValue_LINE; j++) {
        if (searchWords[i] != null && dialogueValue[j][5] != null && dialogueValue[j][6] != null) {
          if (i+1 < searchWords_N && dialogueValue[j][5].equals(searchWords[i] + "/" + searchWords[i+1]) ) {
            reply[reply_LINE][0] = dialogueValue[j][5];
            wordPoint += float(dialogueValue[j][6]);
            Find = true;
          }
        }
      }
      if (Find) {
        reply[reply_LINE][1] = Float.toString(wordPoint);
        if (I ==50) {
          reply[reply_LINE][2] = "Ex";
        }
        reply_LINE++;
      }
    }
  
    for (int i = 0; i < searchWords_N; i++ ) {
      boolean Find = false;
      float wordPoint = 0;
      for (int j = 0; j < dialogueValue_LINE; j++) {
        if (searchWords[i] != null && dialogueValue[j][5] != null && dialogueValue[j][6] != null) {
          if (i+2 < searchWords_N && dialogueValue[j][5].equals(searchWords[i] + "/" + searchWords[i+2]) ) {
            reply[reply_LINE][0] = dialogueValue[j][5];
            wordPoint += float(dialogueValue[j][6]);
            Find = true;
          }
        }
      }
      if (Find) {
        reply[reply_LINE][1] = Float.toString(wordPoint);
        if (I ==50) {
          reply[reply_LINE][2] = "Ex";
        }
        reply_LINE++;
      }
    }
  
    if (I == 50) {
      for (int i = 0; i < searchWords_N; i++ ) {
        factorWords[factorWords_LINE][0] = Integer.toString(0);
        factorWords[factorWords_LINE][1] = searchWords[i];
        factorWords[factorWords_LINE][2] = Integer.toString(0);
        factorWords_LINE++;
      }
  
      for (int i = 0; i < searchWords_N; i++ ) {
        for (int j = 0; j < dialogueValue_LINE; j++) {
          if (searchWords[i] != null && dialogueValue[j][5] != null) {
            String[] rifelationWord = dialogueValue[j][5].split("/", 0);
            boolean Still = true;
            float wordPoint = 0;
            if (dialogueValue[j][6] != null) {
              wordPoint = float(dialogueValue[j][6]);
            }
            if (rifelationWord[0].equals(searchWords[i])) {
              if (i < searchWords_N - 1 && rifelationWord[1].equals(searchWords[i+1])) {  
              } else if (i < searchWords_N - 2 && rifelationWord[1].equals(searchWords[i+2])) {
              } else {
                for (int k = searchWords_N; k < factorWords_LINE+1; k++) {
                  if (rifelationWord[1].equals(factorWords[k][1]) && Integer.toString(i + 1).equals(factorWords[k][0])) {
                    float a = 0;
                    if (factorWords[k][2] != null) {
                      a = float(factorWords[k][2]);
                    }
                    factorWords[k][2] = Float.toString(a + wordPoint);
                    Still = false;
                  }
                }
                if (Still) {
                  factorWords[factorWords_LINE][0] = Integer.toString(i + 1);
                  factorWords[factorWords_LINE][1] = rifelationWord[1];
                  factorWords[factorWords_LINE][2] = Float.toString(wordPoint);
                  factorWords_LINE++;
                }
              }
            } else if (rifelationWord[1].equals(searchWords[i])) {
              if (i > 1 && rifelationWord[0].equals(searchWords[i-1])) {           
              } else if (i > 2 && rifelationWord[0].equals(searchWords[i-2])) {
              } else {
                 
                for (int k = searchWords_N; k < factorWords_LINE+1; k++) {
                  if (rifelationWord[0].equals(factorWords[k][1]) && Integer.toString(100 + i + 1).equals(factorWords[k][0])) {
                    float a = 0;
                    if (factorWords[k][2] != null) {
                      a = float(factorWords[k][2]);
                    }
                    factorWords[k][2] = Float.toString(a + wordPoint);
                    Still = false;
                  }
                }
                if (Still) {
                  factorWords[factorWords_LINE][0] = Integer.toString(100 + i + 1); 
                  factorWords[factorWords_LINE][1] = rifelationWord[0];
                  factorWords[factorWords_LINE][2] = Float.toString(wordPoint);
                  factorWords_LINE++;
                }
              }
            }
          }      
        }
      }
    }
  
// 評価
//    println(searchSentence);
    for (int i = 0; i < searchWords_N; i++ ) {
       print(searchWords[i]+ "\t");
     
    }  print("\n");
  
    float SumPoint = 0;
    float AbsPoint = 0;
    float SumExPoint = 0;
    float AbsExPoint = 0;
    for (int i = 0; i < reply_LINE; i++ ) {
      SumPoint += float(reply[i][1]);
      AbsPoint += abs(float(reply[i][1]));
      if (reply[i][2] != null) {
        SumExPoint += float(reply[i][1]);
        AbsExPoint += abs(float(reply[i][1]));
      }
    }
    
    searchWordsExPN = int(SumExPoint/AbsExPoint * 100);
    searchWordsPN = int(SumPoint/AbsPoint * 100);
    
    if (I < 50) {
      if (test50[I][6].equals("p") && searchWordsPN > 0) {
        test_Accuracy++;
      } else if (test50[I][6].equals("n") && searchWordsPN < 0) {
        test_Accuracy++;
      } else if (test50[I][6]==null && searchWordsPN == 0) {
        test_Accuracy++;
      }
      searchWords_N = 0;
    }
  }
  
//  辞書ランキング
  for (int i = 0; i < dialogueValue_LINE; i++ ) {
    boolean notFind = true;
    if (dialogueValue[i][3] != null) {
      for (int j = 0; j < reply_dict_LINE; j++) {
        if (dialogueValue[i][3].equals(reply_dict[j][0]) ) {
          int temp = int(reply_dict[j][2]);
          reply_dict[j][2] = Integer.toString(temp + 1);
          notFind = false;
        }
      }
      if (notFind) {
        reply_dict[reply_dict_LINE][0] = dialogueValue[i][3];
        reply_dict[reply_dict_LINE][1] = dialogueValue[i][4];
        reply_dict[reply_dict_LINE][2] = Integer.toString(1);
        reply_dict_LINE++;
      }
    }
  }
  for (int i = 0; i < reply_dict_LINE; i++ ) {
    for (int j = 0; j < reply_dict_LINE - i; j++ ) {
     if (reply_dict[j][2] != null &&reply_dict[j+1][2] != null && int(reply_dict[j][2]) < int(reply_dict[j+1][2])) {
          String temp1 = reply_dict[j][0];
          String temp2 = reply_dict[j][1];
          String temp3 = reply_dict[j][2];
          reply_dict[j][0] = reply_dict[j+1][0];
          reply_dict[j][1] = reply_dict[j+1][1];
          reply_dict[j][2] = reply_dict[j+1][2];
          reply_dict[j+1][0] = temp1;
          reply_dict[j+1][1] = temp2;
          reply_dict[j+1][2] = temp3;
      }
    }
  }
  

  writer1 = createWriter("csv/dialogueValue.csv");
  for (int i = 0; i < dialogueValue_LINE; i++ ) {
    for (int j = 0; j < MAX_CUE; j++) {
      // CSV保存 
      writer1.print(dialogueValue[i][j] + ",");
      
      // コンソール表示用
//      print(dialogueValue[i][j] + "\t");
    }
    writer1.println();
//    print("\n");
  }
  writer1.flush();
  writer1.close();
  
  println(dialogueValue_LINE);
  
  writer2 = createWriter("csv/reply.csv");
  for (int i = 0; i < reply_LINE; i++ ) {
    for (int j = 0; j < reply_CUE; j++) {
      // CSV保存 
      writer2.print(reply[i][j] + ",");
      
      // コンソール表示用
//      print(reply[i][j] + "\t");
    }
    writer2.println();
//    print("\n");
  }
  writer2.flush();
  writer2.close();
  
  writer3 = createWriter("csv/reply_dict.csv");
  for (int i = 0; i < reply_dict_LINE; i++ ) {
    for (int j = 0; j < reply_CUE; j++) {
      // CSV保存 
      writer3.print(reply_dict[i][j] + ",");
      
      // コンソール表示用
//      print(reply_dict[i][j] + "\t");
    }
    writer3.println();
//    print("\n");
  }
  writer3.flush();
  writer3.close();

  
// Visualizing
  size(1440, 840);
//  fullScreen();
  background(255);
  smooth();
  noStroke();
  
  PFont font = createFont("Ayuthaya-48.vlw",48,true);
  textFont(font);
  
  initNodesAndSprings();
}

void draw() {
  if (savePDF) beginRecord(PDF, timestamp()+".pdf");
  colorMode(RGB, 255);
  background(255);
  
  // let all nodes repel each other
  for (int i = 0 ; i < nodes.length; i++) {
    nodes[i].attract(nodes);
  } 
  // apply spring forces
  for (int i = 0 ; i < springs.length; i++) {
    springs[i].update();
  } 
  // apply velocity vector and update position
  for (int i = 0 ; i < nodes.length; i++) {
    nodes[i].update();
  } 

  if (selectedNode != null) {
    selectedNode.x = mouseX;
    selectedNode.y = mouseY;
  }

  if (extractionDraw) {
// draw springs
    for (int i = 0 ; i < searchWords_N; i++) {
        stroke(199, 196, 223);
      if (float(factorWords[i][2]) > 0) {
        stroke(82, 209, 220);
      } else if (float(factorWords[i][2]) < 0) {
        stroke(198, 15, 123);
      }

      strokeWeight(1.8 + abs(float(factorWords[i][2]))/2);
      line(springs[i].fromNode.x, springs[i].fromNode.y, springs[i].toNode.x, springs[i].toNode.y);
    
      for (int j = i; j < factorWords_LINE; j++) {      
        for (int k = 0; k < reply_LINE; k++) {
          String[] replyNode = reply[k][0].split("/", 0);
          if (replyNode[0].equals(factorWords[i][1]) && replyNode[1].equals(factorWords[j][1]) && int(factorWords[i][0]) == 0 && int(factorWords[j][0]) == 0 ) {
            if (float(reply[k][1]) > 0) {
              stroke(82, 209, 220);
              fill(82, 209, 220);
            } else if (float(reply[k][1]) < 0) {
              stroke(198, 15, 123);
              fill(198, 15, 123);
            } else {
              stroke(192, 188, 199);
              fill(230, 230, 230);
            }
            strokeWeight(1.8 + abs(float(factorWords[i][2]))/2);
            line(nodes[i].x, nodes[i].y, nodes[j].x, nodes[j].y);
           
            textSize(20);
            text(nf(float(reply[k][1]),1,1), (nodes[i].x + nodes[j].x)/2-9, (nodes[i].y + nodes[j].y)/2-9);
          }
        
          if (j < factorWords_LINE-1 && replyNode[0].equals(factorWords[i][1]) && replyNode[1].equals(factorWords[j+1][1]) && int(factorWords[i][0]) == 0 && int(factorWords[j+1][0]) == 0 ) {
            if (float(reply[k][1]) > 0) {
              stroke(82, 209, 220);
              fill(82, 209, 220);
            } else if (float(reply[k][1]) < 0) {
              stroke(198, 15, 123);
              fill(198, 15, 123);
            } else {
              stroke(192, 188, 199);
              fill(230, 230, 230);
            }
            strokeWeight(1.8 + abs(float(factorWords[i][2]))/2);
            line(nodes[i].x, nodes[i].y, nodes[j+1].x, nodes[j+1].y);
              
            textSize(20);
            text(nf(float(reply[k][1]),1,1), (nodes[i].x + nodes[j+1].x)/2-9, (nodes[i].y + nodes[j+1].y)/2-9);
          }
        }
      }
    }
// draw nodes
    noStroke();
    for (int i = 0 ; i < searchWords_N; i++) {
      textSize(12);
      fill(56, 29, 34);
      text(factorWords[i][1], nodes[i].x -9, nodes[i].y -9);
      fill(255);
      ellipse(nodes[i].x, nodes[i].y, nodeDiameter, nodeDiameter);
      fill(104, 176, 171);
      ellipse(nodes[i].x, nodes[i].y, nodeDiameter-4, nodeDiameter-4);
    }

  } else {
// draw springs
    for (int i = 0 ; i < factorWords_LINE; i++) {
      if (i < searchWords_N) {
        stroke(199, 196, 223);
      } else {
        stroke(192, 188, 199);
      }
            
      if (float(factorWords[i][2]) > 0) {
        stroke(82, 209, 220);
      } else if (float(factorWords[i][2]) < 0) {
        stroke(198, 15, 123);
      }

      strokeWeight(1.8 + abs(float(factorWords[i][2]))/2);
      line(springs[i].fromNode.x, springs[i].fromNode.y, springs[i].toNode.x, springs[i].toNode.y);
    
      for (int j = i; j < factorWords_LINE; j++) {
        if (factorWords[i][1].equals(factorWords[j][1])) {
          stroke(230, 230, 230);
          strokeWeight(1);
          line(nodes[i].x, nodes[i].y, nodes[j].x, nodes[j].y);
        }
      
        for (int k = 0; k < reply_LINE; k++) {
          String[] replyNode = reply[k][0].split("/", 0);
          if (replyNode[0].equals(factorWords[i][1]) && replyNode[1].equals(factorWords[j][1]) && int(factorWords[i][0]) == 0 && int(factorWords[j][0]) == 0 ) {
            if (float(reply[k][1]) > 0) {
              stroke(82, 209, 220);
            } else if (float(reply[k][1]) < 0) {
              stroke(198, 15, 123);
            } else {
              stroke(192, 188, 199);
            }
            strokeWeight(1.8 + abs(float(factorWords[i][2]))/2);
            line(nodes[i].x, nodes[i].y, nodes[j].x, nodes[j].y);
          }
        
          if (j < factorWords_LINE-1 && replyNode[0].equals(factorWords[i][1]) && replyNode[1].equals(factorWords[j+1][1]) && int(factorWords[i][0]) == 0 && int(factorWords[j+1][0]) == 0 ) {
            if (float(reply[k][1]) > 0) {
              stroke(82, 209, 220);
            } else if (float(reply[k][1]) < 0) {
              stroke(198, 15, 123);
            } else {
              stroke(192, 188, 199);
            }
            strokeWeight(1.8 + abs(float(factorWords[i][2]))/2);
            line(nodes[i].x, nodes[i].y, nodes[j+1].x, nodes[j+1].y);
          }
        }
      }
    }
// draw nodes
    noStroke();
    for (int i = 0 ; i < factorWords_LINE; i++) {
      textSize(12);
      fill(56, 29, 34);
      text(factorWords[i][1], nodes[i].x -9, nodes[i].y -9);
      fill(255);
      ellipse(nodes[i].x, nodes[i].y, nodeDiameter, nodeDiameter);
      if (i < searchWords_N) {
        fill(104, 176, 171);
      } else if (int(factorWords[i][0]) < 100) {
        fill(98, 157, 175);
      } else if (int(factorWords[i][0]) > 100) {
        fill(143, 192, 169);
      }
      ellipse(nodes[i].x, nodes[i].y, nodeDiameter-4, nodeDiameter-4);
    }

  }
  
  
// draw UI
  textSize(32);
  fill(56, 29, 34);
  text("教師データ数：" + test_N, 1000, 50);
  text("含有辞書語数：" + reply_dict_LINE, 1000, 85);
  
  if (dataDraw) {
    textSize(8);
    fill(56, 29, 34);
    for (int I = 0; I < test_N; I++) {
      int i = dialogueRandomLine[I] - 1;
      text(dialogue[i][2], 1050, 220 + 10*I - wordsUpDown);
    }
  }
  
  if (rankingDraw) {
    textSize(12);
    for (int i = 0; i < reply_dict_LINE; i++) {      
      if (reply_dict[i][1].equals("p") ) {
        fill(82, 209, 220);
      } else if (reply_dict[i][1].equals("n")) {
        fill(198, 15, 123);
      }
      text(reply_dict[i][0], 1090, 220 + 18*i - wordsUpDown);
      fill(56, 29, 34);
      text(reply_dict[i][2], 1160, 220 + 18*i - wordsUpDown);
    }
  }

  
  textSize(32);
  fill(56, 29, 34);
  text("「" + searchSentence + "」", 10, 50);

  textSize(18);
  for (int i = 0; i < searchWords_N; i++ ) {
      text(searchWords[i], 32, 90 + 24*i);
  }
  
  textSize(36);
  fill(192, 188, 199);
  for (int i = 0; i < searchWords_N; i++ ) {
      text("％", 1040 + 52*Float.toString(test_Accuracy/50*100).length(), 180);
  }
  
  textSize(36);
  fill(192, 188, 199);
  for (int i = 0; i < searchWords_N; i++ ) {
      text("％", 218 + 52*Integer.toString(searchWordsExPN).length(), 180);
  }
  
  textSize(86);
  colorMode(HSB, 360);
  fill(100 + test_Accuracy/50*100, 32*3.6, 92*3.6);
  text(nf(test_Accuracy/50*100,0,1), 1050, 180);
  
  textSize(86);
  colorMode(HSB, 360);
  fill(100+searchWordsExPN, 32*3.6, 92*3.6);
  text(searchWordsExPN, 210, 180);

  
  if (savePDF) {
    savePDF = false;
    println("saving to pdf – finishing");
    endRecord();
  }
}


void initNodesAndSprings() {
  // init nodes
  float rad = nodeDiameter/2;
  for (int i = 0; i < nodes.length; i++) {
    nodes[i] = new Node(width/2+random(-200, 200), height/2+random(-200, 200));
    nodes[i].setBoundary(rad, rad, width-rad, height-rad);
    nodes[i].setRadius(100);
    nodes[i].setStrength(-5);
  } 

  // set springs randomly
  springs = new Spring[0];

  for (int j = 0 ; j < factorWords_LINE; j++) {
    int r = 0;
    if (int(factorWords[j][0]) == 0) {
      r = j+1;
      if (j == (searchWords_N - 1)) {
      r = j;
      }
    } else if (int(factorWords[j][0]) < 100) {
      r = int(factorWords[j][0]) - 1;
    } else if (int(factorWords[j][0]) > 100) {
      r = int(factorWords[j][0]) - 101;
    }
    
    Spring newSpring = new Spring(nodes[j], nodes[r]);
    newSpring.setLength(80);
    newSpring.setStiffness(0.5);
    springs = (Spring[]) append(springs, newSpring);
  }
}



void mousePressed() {
  // Ignore anything greater than this distance
  float maxDist = 20;
  for (int i = 0; i < nodes.length; i++) {
    Node checkNode = nodes[i];
    float d = dist(mouseX, mouseY, checkNode.x, checkNode.y);
    if (d < maxDist) {
      selectedNode = checkNode;
      maxDist = d;
    }
  }
}

void mouseReleased() {
  if (selectedNode != null) {
    selectedNode = null;
  }
}

void keyPressed() {
  if (key == CODED) {     
    if (keyCode == UP) {
       wordsUpDown += 30;
    } else if (keyCode == DOWN) {
       wordsUpDown -= 30;
    }
  }

  
  if(key=='s' || key=='S') saveFrame(timestamp()+"_##.png"); 

  if(key=='p' || key=='P') {
    savePDF = true; 
    println("saving to pdf - starting (this may take some time)");
  }

  if(key=='r' || key=='R') {
    background(255);
    initNodesAndSprings();
  }
  
  if(key=='t' || key=='T') {
    if (dataDraw) {
      dataDraw = false;
    } else {
      dataDraw = true;
    }
  }
  
  if(key=='e' || key=='E') {
    if (extractionDraw) {
      extractionDraw = false;
    } else {
      extractionDraw = true;
    }
  }
  
  if(key=='d' || key=='D') {
    if (rankingDraw) {
      rankingDraw = false;
    } else {
      rankingDraw = true;
    }
  } 
}

String timestamp() {
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", Calendar.getInstance());
}