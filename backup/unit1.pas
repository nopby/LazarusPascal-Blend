unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  LCLIntf, ExtCtrls, ExtDlgs, Math;

type

  { TForm1 }
  Bmp = Array[0..1000,0..1000] of byte;
  TForm1 = class(TForm)
    OpenPictureDialog1: TOpenPictureDialog;
    Save: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Proses: TButton;
    SavePictureDialog1: TSavePictureDialog;
    Target6: TImage;
    Panel12: TPanel;
    Target5: TImage;
    Panel10: TPanel;
    Target4: TImage;
    Panel8: TPanel;
    Source4: TImage;
    Panel7: TPanel;
    Target3: TImage;
    Source3: TImage;
    Panel5: TPanel;
    Panel6: TPanel;
    Source1: TImage;
    Target1: TImage;
    Source2: TImage;
    Target2: TImage;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    ScrollBox1: TScrollBox;
    procedure ProsesClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Grayscale(Bitmap: TBitmap;var R,G,B,Grays: Bmp);
    procedure SaveClick(Sender: TObject);
    procedure Source1Click(Sender: TObject);
    procedure Target1Click(Sender: TObject);
    procedure Threshold(Bitmap:TBitmap;var Grays: Bmp);
    procedure RGBtoHSV(Bitmap: TBitmap; var R,G,B: Bmp);
    procedure Draw(Bmp: TBitmap; Grays: Bmp; var Image: TImage);
    procedure Opening(Bitmap: TBitmap;var Biner: Bmp);
    procedure Blur(Bitmap: TBitmap; var Grays: Bmp);
    function Truncate(Value: Integer): Integer;
    procedure Sketch(Bitmap: TBitmap; var Grays: Bmp);
    procedure Erosi(Bitmap: TBitmap;var Biner: Bmp);
    procedure Invers(Bitmap: TBitmap; var Grays: Bmp);
    procedure Union(SourceBitmap,TargetBitmap: TBitmap; var Grays,Grays1: Bmp);
    procedure Intersection(SourceBitmap,TargetBitmap: TBitmap; var Grays,Grays1: Bmp);
    procedure InitBitmap(Bitmap: TBitmap; var R,G,B: Bmp; var Image: TImage);
    procedure Dilasi(Bitmap: TBitmap;var Biner: Bmp);
    procedure DrawRGB(Bitmap: TBitmap;var Mask: Bmp; R,G,B: Integer; var Image: TImage);
  private

  public
    BitmapR,BitmapG,BitmapB, BitmapR1,BitmapG1,BitmapB1,Grays,Grays1 : Bmp;
    W,H,W1,H1: Integer;
    CekSource,CekTarget,CekProses: Boolean;
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.ProsesClick(Sender: TObject);
var
  Bmp,Bmp1 : TBitmap;
begin
  if (CekSource=True) AND (CekTarget=True) then
  begin
    Bmp := TBitmap.Create;
    Bmp.SetSize(W,H);
    Bmp1 := TBitmap.Create;
    Bmp1.SetSize(W1,H1);

    Grayscale(Bmp,BitmapR,BitmapG,BitmapB,Grays);
    Draw(Bmp,Grays,Source2);

    Grayscale(Bmp1,BitmapR1,BitmapG1,BitmapB1,Grays1);
    Draw(Bmp1,Grays1,Target2);

    Threshold(Bmp,Grays);
    Opening(Bmp,Grays);
    Draw(Bmp,Grays,Source3);

    Threshold(Bmp1,Grays1);
    Opening(Bmp1,Grays1);
    Draw(Bmp1,Grays1,Target3);

    Sketch(Bmp,Grays);
    Draw(Bmp,Grays,Source4);

    Sketch(Bmp1,Grays1);
    Draw(Bmp1,Grays1,Target4);

    Union(Bmp,Bmp1,Grays,Grays1);
    Draw(Bmp1,Grays1,Target5);

    Invers(Bmp1,Grays1);
    Draw(Bmp1,Grays1,Target6);

    CekProses:=True;
    Bmp.Free;
    Bmp1.Free;
  end
  else
  begin
    ShowMessage('Masukkan Source Image dan Target Image');
  end;



end;

procedure TForm1.FormShow(Sender: TObject);
begin
  CekSource:= False;
  CekTarget:= False;
  CekProses:= False;
end;

procedure TForm1.InitBitmap(Bitmap: TBitmap; var R,G,B: Bmp; var Image: TImage);
var
  x,y: Integer;
begin
  for y:=1 to Bitmap.Height-1 do
  begin
    for x:=1 to Bitmap.Width-1 do
    begin
      R[x,y]:=Red(Image.Canvas.Pixels[x,y]);
      G[x,y]:=Green(Image.Canvas.Pixels[x,y]);
      B[x,y]:=Blue(Image.Canvas.Pixels[x,y]);
    end;
  end;
end;



procedure TForm1.Union(SourceBitmap,TargetBitmap: TBitmap; var Grays,Grays1: Bmp);
var
  x,y: Integer;
  Wunion,Hunion: Integer;
begin
  Wunion:=Max(SourceBitmap.Width,TargetBitmap.Width);
  Hunion:=Max(SourceBitmap.Height,TargetBitmap.Height);

  for y:=1 to Hunion-1 do
  begin
    for x:=1 to Wunion-1 do
    begin
      Grays1[x,y]:=Truncate(Grays1[x,y]+Grays[x,y]);
    end;
  end;
end;

procedure TForm1.Intersection(SourceBitmap,TargetBitmap: TBitmap; var Grays,Grays1: Bmp);
var
  x,y: Integer;
  Winter,Hinter: Integer;
begin
  Winter:=Max(SourceBitmap.Width,TargetBitmap.Width);
  Hinter:=Max(SourceBitmap.Height,TargetBitmap.Height);
  for y:=1 to Hinter-1 do
  begin
    for x:=1 to Winter-1 do
    begin
      Grays1[x,y]:=Truncate(Grays1[x,y]-Grays[x,y]);
    end;
  end;
end;

procedure TForm1.Invers(Bitmap: TBitmap; var Grays: Bmp);
var
  x,y: Integer;
begin
  for y:=1 to Bitmap.Height-1 do
  begin
    for x:=1 to Bitmap.Width-1 do
    begin
      Grays[x,y]:=255-Grays[x,y];
    end;
  end;
end;

procedure TForm1.Blur(Bitmap: TBitmap; var Grays: Bmp);
var
  x,y,xK,yK: Integer;
  Sum: Real;
  K: Array[1..100,1..100] of Real;
  Temp: Bmp;
begin
  for y:=1 to 3 do
  begin
    for x:=1 to 3 do
    begin
      K[x,y]:=1/9;
    end;
  end;

  for y:=1 to Bitmap.Height do
  begin
    for x:=1 to Bitmap.Width do
    begin
      Sum:=0;
      for yK:=1 to 3 do
      begin
        for xK:=1 to 3 do
        begin
          Sum+=Grays[x-(xK-2),y-(yK-2)]*K[4-xK,4-yK];
        end;
      end;
      Temp[x,y]:=Truncate(Round(Sum));
    end;
  end;
  for y:=1 to Bitmap.Height-1 do
  begin
    for x:=1 to Bitmap.Width-1 do
    begin
      Grays[x,y]:=Temp[x,y];
    end;
  end;
end;

procedure TForm1.Sketch(Bitmap: TBitmap; var Grays: Bmp);
var
  x,y,xK,yK: Integer;
  Sum: Integer;
  K: array[1..3,1..3] of Integer = ((-1,-1,-1),(-1,8,-1),(-1,-1,-1));
  Temp: Bmp;
begin
  {Pembuatan Padding}
  for y:=1 to Bitmap.Height-1 do
  begin
    Grays[0,y]:=Grays[1,y];
    Grays[Bitmap.Width,y]:=Grays[Bitmap.Width-1,y];
  end;

  for x:=1 to Bitmap.Width-1 do
  begin
    Grays[x,0]:=Grays[x,y];
    Grays[x,Bitmap.Height]:=Grays[x,Bitmap.Height-1];
  end;

  {Proses Deteksi Tepi}
  for y:=1 to Bitmap.Height-1 do
  begin
    for x:=1 to Bitmap.Width-1 do
    begin
      Sum:=0;
      for yK:=1 to 3 do
      begin
        for xK:=1 to 3 do
        begin
          Sum+=Grays[x-(xK-2),y-(yK-2)]*K[4-xK,4-yK];
        end;
      end;
      Temp[x,y]:=Truncate(Sum);
    end;
  end;

  {Output}
  for y:=1 to Bitmap.Height-1 do
  begin
    for x:=1 to Bitmap.Width-1 do
    begin
      Grays[x,y]:=Temp[x,y];
    end;
  end;
end;

procedure TForm1.Draw(Bmp: TBitmap; Grays: Bmp; var Image: TImage);
var
  x,y: Integer;
begin
  for y:=1 to Bmp.Height-1 do
  begin
    for x:=1 to Bmp.Width-1 do
    begin
      Bmp.Canvas.Pixels[x,y]:=RGB(Grays[x,y],Grays[x,y],Grays[x,y]);
    end;
  end;
  Image.Picture.Bitmap.Assign(Bmp);
  Image.Invalidate;
end;

procedure TForm1.DrawRGB(Bitmap: TBitmap;var Mask: Bmp; R,G,B: Integer; var Image: TImage);
var
  x,y: Integer;
begin
  for y:=1 to Bitmap.Height-1 do
  begin
    for x:=1 to Bitmap.Width-1 do
    begin
      if Mask[x,y]=0 then
      begin
        Bitmap.Canvas.Pixels[x,y]:=RGB(R,G,B);
      end;
    end;
  end;
  Image.Picture.Bitmap.Assign(Bitmap);
  Image.Invalidate;
end;


procedure TForm1.Opening(Bitmap: TBitmap;var Biner: Bmp);
begin
  Dilasi(Bitmap,Biner);
  Erosi(Bitmap,Biner);
end;


procedure TForm1.Dilasi(Bitmap: TBitmap;var Biner: Bmp);
var
  x,y,xSE,ySE: Integer;
  SE: Array[1..3,1..3] of Byte = ((0,0,0),(0,0,0),(0,0,0));
  Sum,Binary: Boolean;
  Temp: Bmp;
begin

  {Proses Dilasi}
  for y:=1 to Bitmap.Height-1 do
   begin
     for x:=1 to Bitmap.Width-1 do
     begin
       Sum:= False;
       Binary:= False;
       for ySE:=1 to 3 do
       begin
         for xSE:=1 to 3 do
         begin
           if (Biner[x-(xSE-2),y-(ySE-2)]<>SE[xSE,ySE]) then
           begin
             Binary:=True;
           end
           else
           begin
             Binary:=False;
           end;
           Sum:=Sum OR Binary;
         end;
       end;
       if Sum then
       begin
         Temp[x,y]:=255;
       end
       else
       begin
         Temp[x,y]:=0;
       end;
     end;
   end;

  {Output}
  for y:=1 to Bitmap.Height-1 do
  begin
    for x:=1 to Bitmap.Width-1 do
    begin
      Biner[x,y]:=Temp[x,y];
    end;
  end;
end;

procedure TForm1.Erosi(Bitmap: TBitmap;var Biner: Bmp);
var
  x,y,xSE,ySE: Integer;
  SE: Array[1..3,1..3] of Byte = ((0,0,0),(0,0,0),(0,0,0));
  Sum,Binary: Boolean;
  Temp: Bmp;
begin

  {Proses Erosi}
  for y:=1 to Bitmap.Height-1 do
   begin
     for x:=1 to Bitmap.Width-1 do
     begin
       Sum:= False;
       Binary:= False;
       for ySE:=1 to 3 do
       begin
         for xSE:=1 to 3 do
         begin
           if (Biner[x-(xSE-2),y-(ySE-2)]=SE[xSE,ySE]) then
           begin
             Binary:=True;
           end
           else
           begin
             Binary:=False;
           end;
           Sum:=Sum OR Binary;
         end;
       end;
       if Sum then
       begin
         Temp[x,y]:=0;
       end
       else
       begin
         Temp[x,y]:=255;
       end;
     end;
   end;

  {Output}
  for y:=1 to Bitmap.Height-1 do
  begin
    for x:=1 to Bitmap.Width-1 do
    begin
      Biner[x,y]:=Temp[x,y];
    end;
  end;
end;

procedure TForm1.Grayscale(Bitmap: TBitmap;var R,G,B,Grays: Bmp);
var
  x,y: Integer;
begin
  for y:=1 to Bitmap.Height-1 do
  begin
    for x:=1 to Bitmap.Width-1 do
    begin
      Grays[x,y]:=(R[x,y]+G[x,y]+B[x,y])div 3;
    end;
  end;
end;

procedure TForm1.SaveClick(Sender: TObject);
begin
  if CekProses=True then
  begin
    if SavePictureDialog1.Execute then
    begin
      Target6.Picture.SaveToFile(SavePictureDialog1.FileName);
    end;
  end
  else
  begin
    ShowMessage('Hasil belum ada');
  end;
end;

procedure TForm1.Source1Click(Sender: TObject);
var
  x,y: Integer;
  SourceBmp: TBitmap;
begin
  if OpenPictureDialog1.Execute then
  begin
    Source1.Picture.LoadFromFile(OpenPictureDialog1.FileName);
    SourceBmp:= TBitmap.Create;
    SourceBmp.SetSize(200,200);
    W:=SourceBmp.Width;
    H:=SourceBmp.Height;
    SourceBmp.Canvas.StretchDraw(Rect(0,0,W,H),Source1.Picture.Bitmap);

    for y:=0 to H do
    begin
      for x:=0 to W do
      begin
        BitmapR[x+1,y+1]:=Red(SourceBmp.Canvas.Pixels[x,y]);
        BitmapG[x+1,y+1]:=Green(SourceBmp.Canvas.Pixels[x,y]);
        BitmapB[x+1,y+1]:=Blue(SourceBmp.Canvas.Pixels[x,y]);
      end;
    end;
    Source1.Picture.Bitmap.Assign(SourceBmp);
    Source1.Invalidate;
    SourceBmp.Free;
    CekSource:=True;
  end;


end;

procedure TForm1.Target1Click(Sender: TObject);
var
  x,y: Integer;
  TargetBmp: TBitmap;
begin
  if OpenPictureDialog1.Execute then
  begin
    Target1.Picture.LoadFromFile(OpenPictureDialog1.Filename);
    TargetBmp:=TBitmap.Create;
    TargetBmp.SetSize(200,200);
    H1:=TargetBmp.Height;
    W1:=TargetBmp.Width;
    TargetBmp.Canvas.StretchDraw(Rect(0,0,W,H),Target1.Picture.Bitmap);
    for y:=0 to H1 do
    begin
      for x:=0 to W1 do
      begin
        BitmapR1[x+1,y+1]:=Red(TargetBmp.Canvas.Pixels[x,y]);
        BitmapG1[x+1,y+1]:=Green(TargetBmp.Canvas.Pixels[x,y]);
        BitmapB1[x+1,y+1]:=Blue(TargetBmp.Canvas.Pixels[x,y]);
      end;
    end;
    Target1.Picture.Bitmap.Assign(TargetBmp);
    Target1.Invalidate;
    TargetBmp.Free;
    CekTarget:=True;
  end;
end;

procedure TForm1.Threshold(Bitmap:TBitmap;var Grays: Bmp);
var
  x,y,c: Integer;
  M1: Real;
begin
  {Inisialisasi}
  c:=0;
  M1:=0;
  {------------}

  {Pembuatan Mean}
  for y:=1 to Bitmap.Height-1 do
  begin
    for x:=1 to Bitmap.Width-1 do
    begin
      M1+=Grays[x,y];
      c+=1;
    end;
  end;
  M1/=C;
  {--------------}

  {Proses Binerisasi dan output}
  for y:=1 to Bitmap.Height-1 do
  begin
    for x:=1 to Bitmap.Width-1 do
    begin
      if Grays[x,y]<M1 then
      begin
        Grays[x,y]:=0;
      end
      else
      begin
        Grays[x,y]:=255;
      end;
    end;
  end;
  {---------------}
end;

procedure TForm1.RGBtoHSV(Bitmap: TBitmap;var R,G,B: Bmp);
var
  x,y: Integer;
  BH,BS,BV,k,TempR,TempG,TempB: Real;
begin
  for y:=1 to Bitmap.Height-1 do
  begin
    for x:=1 to Bitmap.Width-1 do
    begin

      BV:=Max(R[x,y],Max(G[x,y],B[x,y]));
      k:=Min(R[x,y],Min(G[x,y],B[x,y]));
      if BV <> 0 then
      begin
        BS:=(BV-k)/BV;
      end
      else
      begin
        BS:=0;
      end;

      if BS <> 0 then
      begin
        TempR:= (BV-R[x,y])/(BV-k);
        TempG:= (BV-G[x,y])/(BV-k);
        TempB:= (BV-B[x,y])/(BV-k);
        if BV=R[x,y] then
        begin
          if k=G[x,y] then
          begin
            BH:=5+TempB;
          end
          else
          begin
            BH:=1-TempG;
          end;
        end;

        if BV=G[x,y] then
        begin
          if k=B[x,y] then
          begin
            BH:=1+TempR;
          end
          else
          begin
            BH:=3-TempB
          end;
        end
        else if k=TempR then
        begin
          BH:=3+TempG;
        end
        else
        begin
          BH:=5-TempR;
        end;
        BH:=BH*60;
      end
      else
      begin
        BH:=0;
      end;
      R[x,y]:=Truncate(Round(BH));
      G[x,y]:=Truncate(Round(BS));
      B[x,y]:=Truncate(Round(BV));
    end;
  end;
end;

function TForm1.Truncate(Value: Integer): Integer;
begin
  if Value>255 then
  begin
    Result:=255;
  end
  else if Value<0 then
  begin
    Result:=0;
  end
  else
  begin
    Result:=Value;
  end;
end;


end.

