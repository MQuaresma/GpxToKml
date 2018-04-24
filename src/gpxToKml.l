%option main
%x TRACKPOINTS TRACKPOINT

%{
void printHead();
void printFinal();
%}

%%
\<trk\>                                     {BEGIN TRACKPOINTS; printHead();}
<TRACKPOINTS>\<trkpt                        {BEGIN TRACKPOINT;}
<TRACKPOINT>(lat|lon)=\"[0-9]+\.[0-9]+\"    {printf("%s, ",strndup(yytext+5,strlen(yytext+5)-1));}
<TRACKPOINT>\<\/trkpt\>                     {printf("0\n"); BEGIN TRACKPOINTS;}
<TRACKPOINTS>\<\/trk\>                      {BEGIN INITIAL; printFinal();}
<*>.|\n                                     {}
%%

void printHead(){
    printf("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n");
    printf("<kml xmlns=\"http://www.opengis.net/kml/2.2\">\n");
    printf("<Document>\n");
    printf("<Placemark>\n");
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
