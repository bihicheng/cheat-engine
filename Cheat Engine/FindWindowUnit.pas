unit FindWindowUnit;

{$MODE Delphi}

interface

uses
  LCLIntf, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,CEFuncProc,ComCtrls, ExtCtrls, LResources, memscan;

const wm_fw_scandone=wm_user+1;
type

  { TFindWindow }

  TFindWindow = class(TForm)
    ProgressBar: TProgressBar;
    Panel1: TPanel;
    labelType: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    labelArray: TLabel;
    editStart: TEdit;
    EditStop: TEdit;
    rbText: TRadioButton;
    rbArByte: TRadioButton;
    cbUnicode: TCheckBox;
    Timer1: TTimer;
    Panel2: TPanel;
    btnOK: TButton;
    btnCancel: TButton;
    Scanvalue: TEdit;
    procedure btnCancelClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
    memscan: TMemScan;
  public
    { Public declarations }
    firstscan: boolean;
  end;

var
  FindWindow: TFindWindow;

implementation

uses MemoryBrowserFormUnit;

resourcestring
  rsNothingFound = 'Nothing found';
  rsTheSpecifiedRangeIsInvalid = 'The specified range is invalid';



procedure TFindWindow.btnOKClick(Sender: TObject);
var start,stop,temp: dword;
    //cb: TCheckbox;
    valtype: TVariableType;
    i: integer;
    x: ptruint;
begin


  if memscan<>nil then
    freeandnil(memscan);
  
  try
    start:=StrToQWordEx('$'+editStart.text);
    stop:=StrToQWordEx('$'+editstop.Text);
  except
    raise exception.Create(rsTheSpecifiedRangeIsInvalid);
  end;

  if start>stop then
  begin
    temp:=start;
    start:=stop;
    stop:=temp;
  end;


  if rbText.checked then valtype:=vtString else valtype:=vtByteArray;



  memscan:=TMemscan.create(nil);
  memscan.onlyone:=true;
  memscan.scanCopyOnWrite:=scanDontCare;
  memscan.scanExecutable:=scanDontCare;
  memscan.scanWritable:=scanDontCare;


  try
    memscan.firstscan(soExactValue, valtype, rtRounded, scanvalue.text, '', start, stop, true, false, cbunicode.checked, false, fsmNotAligned);
    memscan.waittilldone;

    if memscan.GetOnlyOneResult(x) then
    begin
      MemoryBrowser.memoryaddress:=x;
      modalresult:=mrok;
    end else
    begin
      //showmessage(rsNothingFound);
      //wtf...
      freeandnil(memscan);

      raise exception.Create(rsNothingFound); //this causes a crash
      //raise exception.Create('Nothing found'); //this does not
    end;
  finally
    if memscan<>nil then
      freeandnil(memscan);
  end;

end;

procedure TFindWindow.btnCancelClick(Sender: TObject);
begin

end;

procedure TFindWindow.FormShow(Sender: TObject);
begin
  progressbar.Position:=0;
  
  if firstscan then
  begin


    editstart.Text:=Inttohex(memorybrowser.memoryaddress, processhandler.pointersize*2);

    if processhandler.is64bit then
      editstop.text:='7FFFFFFFFFFFFFFF';

    height:=185;
    progressbar.Top:=96;

    labelType.visible:=true;
    labelarray.visible:=true;
    rbtext.visible:=true;
    rbArByte.visible:=true;
    scanvalue.Visible:=true;
    btnOK.visible:=true;
    btnCancel.visible:=true;
    EditStop.visible:=true;
    editStart.visible:=true;
    label2.Visible:=true;
    label3.Visible:=true;
    Scanvalue.SetFocus;
  end
  else
  begin
    clientheight:=progressbar.height+4;
    progressbar.top:=2;

    labelType.visible:=false;
    labelarray.visible:=false;
    rbtext.visible:=false;
    rbArByte.visible:=false;
    scanvalue.Visible:=false;
    btnOK.visible:=false;
    btnCancel.visible:=false;
    EditStop.visible:=false;
    editStart.visible:=false;
    label2.Visible:=false;
    label3.Visible:=false;
    timer1.enabled:=true; //bah, I wanted to do execute here but it seems thats not possible
  end;
end;

procedure TFindWindow.Timer1Timer(Sender: TObject);
begin
  timer1.enabled:=false;
  btnOK.click;
  close;
end;

initialization
  {$i FindWindowUnit.lrs}

end.





















