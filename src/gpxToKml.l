%option main
%x TRACKPOINTS TRACKPOINT

%{
void printHead();
void printFinal();
void printLine();
char *lat;
%}

%%
\<trk\>                                                 {BEGIN TRACKPOINTS; printHead();}
<TRACKPOINTS>\<trkpt                                    {BEGIN TRACKPOINT;}
<TRACKPOINTS>\<name\>(.*)?\<\/name\>                    {printf("%s\n",yytext);} 
<TRACKPOINTS>\<trkseg\>                                 {printLine();}
<TRACKPOINT>lat=\"[-+]?[0-9]+(\.[0-9]+)?\"              {lat=strndup(yytext+5,strlen(yytext+5)-1);}
<TRACKPOINT>lon=\"[-+]?[0-9]+(\.[0-9]+)?\"              {printf("%s,%s,",strndup(yytext+5,strlen(yytext+5)-1),lat);}
<TRACKPOINT>\<ele\>[-+]?[0-9]+(\.[0-9]+)?\<\/ele\>      {printf("%s\n",strndup(yytext+5,strlen(yytext+5)-6));BEGIN TRACKPOINTS;}
<TRACKPOINTS>\<\/trk\>                                  {BEGIN INITIAL; printFinal();}
<*>.|\n                                                 {}
%%

void printHead(){
    printf("<?xml version=\"1.0\" encoding=\"utf-8\"?>\n");
    printf("<kml xmlns=\"http://www.opengis.net/kml/2.2\">\n");
    printf("<Document>\n");
    printf("<Placemark>\n");
}

void printLine(){
    printf("<LineString>\n");
    printf("<coordinates>\n");
}

void printFinal(){
    printf("</coordinates>\n");
    printf("</LineString>\n");
    printf("</Placemark>\n");
    printf("</Document>\n");
    printf("</kml>\n");
}
