//---------------------------------------------------------------------------
#include <vcl\vcl.h>
#pragma hdrstop
//---------------------------------------------------------------------------
USERES("RVDemo.res");
USEFORMNS("Unit1.pas", Unit1, Form1);
USEFORMNS("PrintFrm.pas", Printfrm, frmPrint);
USEFORMNS("BackStyl.pas", Backstyl, frmBackStyle);
//---------------------------------------------------------------------------
WINAPI WinMain(HINSTANCE, HINSTANCE, LPSTR, int)
{
	try
	{
		Application->Initialize();
		Application->CreateForm(__classid(TForm1), &Form1);
		Application->CreateForm(__classid(TfrmPrint), &frmPrint);
		Application->CreateForm(__classid(TfrmBackStyle), &frmBackStyle);
		Application->Run();
	}
	catch (Exception &exception)
	{
		Application->ShowException(&exception);
	}
	return 0;
}
//---------------------------------------------------------------------------
