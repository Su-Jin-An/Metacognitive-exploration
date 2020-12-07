#include "stdio.h"
#include "stdlib.h"
#include <windows.h>
#include <math.h>
#include <matrix.h>
#include <mex.h>
#include <chrono>
#include <iostream>
#include "Test_dll.h"

typedef int* ( *pFunctionDLL )();

class MyHook{
public:
	//single ton
	static MyHook& Instance(){
		static MyHook myHook;
		return myHook;
	}	
	HHOOK hook; // handle to the hook	
	void InstallHook(); // function to install our hook
	void UninstallHook(); // function to uninstall our hook

	MSG msg; // struct with information about all messages in our queue
    int flag = 0;
    int PosX = -1;
    int PosY = -1;
    HMODULE lib = LoadLibrary(TEXT("Touch_dll.dll"));
    //HMODULE lib = LoadLibrary(TEXT("mouse_dll.dll"));
	int Messsages(); // function to "deal" with our messages 
};
LRESULT WINAPI MyMouseCallback(int nCode, WPARAM wParam, LPARAM lParam); //callback declaration

int MyHook::Messsages(){   
    auto t1 = std::chrono::system_clock::now();     
    std::chrono::duration<double> elapsed_seconds = std::chrono::system_clock::now()-t1;
    HMODULE lib = MyHook::Instance().lib;
    pFunctionDLL pFunction1 = (pFunctionDLL)GetProcAddress(lib,TEXT("GetData"));
    pFunctionDLL pFunction2 = (pFunctionDLL)GetProcAddress(lib,TEXT("GetPosX"));
    pFunctionDLL pFunction3 = (pFunctionDLL)GetProcAddress(lib,TEXT("GetPosY"));  
    
	while(elapsed_seconds.count() < 0.05){ //while we do not close our application        
        auto t2 = std::chrono::system_clock::now();
        elapsed_seconds = t2 - t1;        
		if (PeekMessage(&msg, NULL, 0, 0, PM_REMOVE)){
			TranslateMessage(&msg);
			DispatchMessage(&msg);
		}
        if(*pFunction1() == 1)
            MyHook::Instance().flag = 1;
        MyHook::Instance().PosX = *pFunction2();            
        MyHook::Instance().PosY = *pFunction3();          
	}
    if(pFunction2 == NULL){
        printf("function2 load fail\n");
    }
    if(pFunction3 == NULL){
        printf("function3 load fail\n");
    }

    //if(*pFunction2() ~= -1 && *pFunction3() ~= -1){  
	return (int)msg.wParam; //return the messages
}

void MyHook::InstallHook(){
	/*
	SetWindowHookEx(
	WM_MOUSE_LL = mouse low level hook type,
	MyMouseCallback = our callback function that will deal with system messages about mouse
	NULL, 0);

	c++ note: we can check the return SetWindowsHookEx like this because:
	If it return NULL, a NULL value is 0 and 0 is false.
	*/
	//LPCSTR dll_path = "C:\\Users\\JJun\\Documents\\Visual Studio 2013\\Projects\\Win32Project5\\Debug\\Test_dll.dll";
	//HMODULE lib = LoadLibrary(dll_path);
    HMODULE lib = MyHook::Instance().lib;
    if(lib){
        HOOKPROC procedure = (HOOKPROC)GetProcAddress(lib, "procedure");
        if (!(hook = SetWindowsHookEx(WH_GETMESSAGE, procedure, lib, 0))){
            mexPrintf("Error: %d \n", GetLastError());
        }
    }
    else
        mexPrintf("Can't find dll!\n");
}

void MyHook::UninstallHook(){
	/*
	uninstall our hook using the hook handle
	*/
	UnhookWindowsHookEx(hook);
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    double *f;
    double *x;
    double *y;
    
    plhs[0] = mxCreateDoubleMatrix(1,1,mxREAL);
    plhs[1] = mxCreateDoubleMatrix(1,1,mxREAL);
    plhs[2] = mxCreateDoubleMatrix(1,1,mxREAL);
    
    f = mxGetPr(plhs[0]);
    x = mxGetPr(plhs[1]);
    y = mxGetPr(plhs[2]);
    
    MyHook::Instance().InstallHook();
    MyHook::Instance().flag = 0;
    MyHook::Instance().Messsages();
    *f = (double) MyHook::Instance().flag;
    *x = (double) MyHook::Instance().PosX;
    *y = (double) MyHook::Instance().PosY;
    MyHook::Instance().UninstallHook();    
}
