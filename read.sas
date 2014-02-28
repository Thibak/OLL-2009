/***********************************************************************************************************/
/***********************************************************************************************************/
/***********************************************************************************************************/
/***********************************************************************************************************/
/*****************                                                                       *******************/
/****************                 ��������� ������ ��������� ���-2009                     ******************/
/*****************                                                                       *******************/
/***********************************************************************************************************/
/***********************************************************************************************************/
/***********************************************************************************************************/
/***********************************************************************************************************/
/*������������� �����*/ *D - sony, Z - ���;
%macro what_OC;
%if &sysscpl = W32_7PRO %then 
	%do;
		%let disk = D; *sony;
	%end;
%else/*%if &sysscpl = "W32_7PRO" %then */ 
	%do;
		%let disk = Z; *���������;
	%end;
%mend;


/*������������ ��*/
/*data comp;*/
/*	OC = "&sysscpl";*/
/*run;*/
/**/
/*proc print data = COMP;*/
/*run;*/
%what_OC;

%let dirURI = &disk.:\AC\OLL-2009\cur_base\; * ���������� � �����;
%let metaFN = meta.txt; * ��� ����� ����������;
%let LN = ALL2009; * ��� ����������;
%let lbs = labels.txt; * ���� � �������� (��� ���� ������ � ����);

Libname &LN "&disk.:\AC\OLL-2009\SAS"; * ������� ���� ������;
filename tranfile "&disk.:\AC\OLL-2009\REG_ARCH_&sysdate9..stc"; * �������� ������������� ������������� �����;

/***********************************************************************************************************/
/************************************* ������ ���� ���������� **********************************************/
/**                                                                                                       **/
/**    ��� ����� ***** ��������� ***** ��� ��������                                                       **/
/**                                                                                                       **/
/***********************************************************************************************************/

OPTIONS CTRYDECIMALSEPARATOR=',' ;

*����������� ���� ����������;
proc import datafile="&dirURI&metaFN" dbms=tab out=&LN..TABLES replace; 
	*delimiter='09'x; * ����������� -- '09'x ���������;
	getnames=yes; * �������� ����� ����������?;
run; 

*������ ������� ������ �� ���-��������� ������;
%macro imprt (src, dst);
	proc import datafile="&dirURI&src" dbms=csv out=&LN..&dst replace; 
		*delimiter='09'x; * ����������� -- '09'x ���������;
		delimiter=';';
		getnames=yes; * �������� ����� ����������?;
		guessingrows=500;  * ��� ����� ����� ����� ��������������, ��� ����������� ������������ ������ ����;
	run; 
%mend imprt;


%macro lbls (tn);
data &LN..&tn;
	SET &LN..&tn;
%include "&dirURI&lbs";
run;
%mend;

*��� ������ ������ ��������� ��������� ������ ��������;
data _Null_; * �� ������� �� ������ ��������;
	set &LN..TABLES; * ��� ������ ����� ������� ����������;
	CALL execute ('%imprt('||FN||','||TN||')'); * ��������� ������ ��������;
	CALL execute ('%lbls('||TN||')'); * ��������� ������ ���������� ��������;
run; 

/*��������!!! ���������� ������ �� ���������*/
proc import datafile="&dirURI.age.txt" dbms=tab out=&LN..tmp_AGE replace; 
		getnames=yes; * �������� ����� ����������?;
		guessingrows=500;  * ��� ����� ����� ����� ��������������, ��� ����������� ������������ ������ ����;
run; 

*�������� � ������������ ����;
proc cport library=&LN file=tranfile;
run;

