unit Unit1;

interface

uses
    Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
    Dialogs, StdCtrls;

type
    TForm1 = class(TForm)
        lst1: TListBox;
        lst2: TListBox;
        edt1: TEdit;
        btn2: TButton;
    lbl1: TLabel;
    lbl2: TLabel;
    edt2: TEdit;
    btn1: TButton;
    lst3: TListBox;
    lst4: TListBox;
    lbl3: TLabel;
    lbl4: TLabel;
    procedure edt1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btn2Click(Sender: TObject);
    procedure edt2KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure btn1Click(Sender: TObject);
    procedure lst1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure lst2KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure lst1DrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure lst2DrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure FormCreate(Sender: TObject);
    private
    { Private declarations }
    public
    { Public declarations }
    end;

type
    BinArray = array of Boolean;

var
    Form1: TForm1;
    ProbeItems: BinArray;
    DirectItems: BinArray;

const
    selectionColor = $006859A6;

implementation

{$R *.dfm}

procedure search();
var
    i, j: Integer;
    lst1IsInLst2, lst2IsInLst1: Boolean;
begin
    Form1.lst3.Clear();
    Form1.lst4.Clear();

    for i := 0 to Form1.lst1.Count - 1 do
        begin
            lst1IsInLst2 := False;
            for j := 0 to Form1.lst2.Count - 1 do
                begin
                    if (Form1.lst1.Items[i] = Form1.lst2.Items[j]) then
                       begin
                            lst1IsInLst2 := True;
                            break;
                       end;
                end;
            if (not lst1IsInLst2) then
                begin
                     Form1.lst3.AddItem(Form1.lst1.Items[i], Form1.lst1);
                     ProbeItems[i] := True;
                end
            else
                begin
                    ProbeItems[i] := False;
                end;
        end;

    for i := 0 to Form1.lst2.Count - 1 do
        begin
            lst2IsInLst1 := False;
            for j := 0 to Form1.lst1.Count - 1 do
                begin
                    if (Form1.lst2.Items[i] = Form1.lst1.Items[j]) then
                       begin
                            lst2IsInLst1 := True;
                            break;
                       end;
                end;
            if (not lst2IsInLst1) then
                begin
                     Form1.lst4.AddItem(Form1.lst2.Items[i], Form1.lst2);
                     DirectItems[i] := True;
                end
            else
                begin
                    DirectItems[i] := False;
                end;
        end;
end;

procedure updateProbeItems();
begin
     SetLength(ProbeItems, Form1.lst1.Count);
     SetLength(DirectItems, Form1.lst2.Count);
     search();
end;

procedure reDrawItem(lst: TListBox; edt: TEdit);
begin
     lst.AddItem('', edt);
     lst.Items.Delete(lst.Count-1);
     lst.ScaleBy(1000, 1000);
end;

procedure markItem(Control: TWinControl; Index: Integer; Rect: TRect; ArrayOfBoolean: BinArray);
begin
    with (Control as TListBox).Canvas do
    begin
        if ArrayOfBoolean[Index] then
           begin
               Brush.Color := selectionColor;
               Font.Color := clWhite;
               Font.Style := [fsBold];
           end;
        FillRect(Rect);
        TextOut(Rect.Left, Rect.Top, (Control as TListBox).Items[Index]);
    end;
end;

procedure addItem(lst: TListBox; lstOther: TListBox; edt: TEdit);
var
    num, tmp: string;
    i, j: Integer;
begin
    begin
        j := 1;
        tmp := edt.Text;
        if (tmp = '') then exit;

        for i:=1 to Length(tmp) do
            begin
                if (j = 4) then
                    begin
                         num := num + ' ' + tmp[i];
                         j := 1;
                    end
                else
                    num := num + tmp[i];
                j := j + 1;
            end;

        lst.Items.Insert(0, num); // ������� � ������ ������
        edt.Text := '';

        reDrawItem(lstOther, edt);
        updateProbeItems();
    end;
end;

procedure clearAll();
begin
    Form1.lst1.Clear();
    Form1.lst2.Clear();
    Form1.lst3.Clear();
    Form1.lst4.Clear();
    Form1.edt1.Text := '';
    Form1.edt2.Text := '';
end;

procedure TForm1.edt1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
    case Key of
        VK_RETURN:
            addItem(lst1, lst2, edt1);
    end;
end;

procedure TForm1.edt2KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
    case Key of
        VK_RETURN:
            addItem(lst2, lst1, edt2);
    end;
end;

procedure TForm1.lst1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
    case Key of
        VK_DELETE:
            begin
                lst1.DeleteSelected();
                reDrawItem(lst2, edt2);
                updateProbeItems();
            end
    end;
end;

procedure TForm1.lst2KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
    case Key of
        VK_DELETE:
            begin
                lst2.DeleteSelected();
                reDrawItem(lst1, edt1);
                updateProbeItems();
            end
    end;
end;

procedure TForm1.btn2Click(Sender: TObject);
begin
    search();
end;

procedure TForm1.btn1Click(Sender: TObject);
begin
    clearAll();
end;

procedure TForm1.lst1DrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
begin
    markItem(Control, Index, Rect, ProbeItems);
end;

procedure TForm1.lst2DrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
begin
    markItem(Control, Index, Rect, DirectItems);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
    SetWindowPos(Form1.Handle, // handle to window
            HWND_TOPMOST, // placement-order handle
            Form1.Left, // horizontal position
            Form1.Top, // vertical position
            Form1.Width, Form1.Height,
            // window-positioning options
            SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE);
end;

end.

