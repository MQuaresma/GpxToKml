%option main
%x TRACKPOINTS TRACKPOINT DESCRIPTION WAYPOINT

%{
void printHead();
void printFinal();
void printLine();
void printFinalTrackPoints();
char *lat;
%}

%%
\<gpx                                              {printHead();}
\<trk\>                                            {BEGIN TRACKPOINTS; printf("<Placemark>\n");}
\<\/gpx\>                                          {printFinal();}
\<wpt                                              {BEGIN WAYPOINT; printf("<Placemark>\n");}

<WAYPOINT>{
\<\/wpt\>                                          {BEGIN INITIAL; printf("</Placemark>\n");}
}

<TRACKPOINTS>{
\<trkpt                                            {BEGIN TRACKPOINT;}
\<name\>(.*)?\<\/name\>                            {BEGIN DESCRIPTION; printf("%s\n",yytext); printf("<description>\n");} 
\<gpxtrkx:TrackStatsExtension(.*)?\>               {BEGIN DESCRIPTION; printf("<description>\n");}
\<\/trk\>                                          {BEGIN INITIAL; printFinalTrackPoints();}
}

<TRACKPOINT>{
lat=\"[-+]?[0-9]+(\.[0-9]+)?\"                     {lat=strndup(yytext+5,strlen(yytext+5)-1);}
lon=\"[-+]?[0-9]+(\.[0-9]+)?\"                     {printf("%s,%s,",strndup(yytext+5,strlen(yytext+5)-1),lat);}
\<ele\>[-+]?[0-9]+(\.[0-9]+)?\<\/ele\>             {printf("%s\n",strndup(yytext+5,strlen(yytext+5)-6)); BEGIN TRACKPOINTS;}
}

<DESCRIPTION>{
\<type\>(.*)?/\<\/type\>                           {printf("Type:%s\n",yytext+6);}
\<gpxtrkx:Distance\>(.*)?/\<\/gpxtrkx:Distance\>   {printf("Distance: %s m\n",yytext+18);};
\<gpxtrkx:Ascent\>(.*)?/\<\/gpxtrkx:Ascent\>       {printf("D+: %s m\n",yytext+16);};
\<gpxtrkx:Descent\>(.*)?/\<\/gpxtrkx:Descent\>     {printf("D-: %s m\n",yytext+17);};
\<gpxtrkx:Calories\>(.*)?/\<\/gpxtrkx:Calories\>   {printf("Calories: %s\n",yytext+18);};
\<trkseg\>                                         {BEGIN TRACKPOINTS; printf("</description>\n"); printLine();}
}

<*>.|\n                                            {}
%%

void printHead(){
    printf("<?xml version=\"1.0\" encoding=\"utf-8\"?>\n");
    printf("<kml xmlns=\"http://www.opengis.net/kml/2.2\">\n");
    printf("<Document>\n");
}

void printLine(){
    printf("<LineString>\n");
    printf("<altitudeMode>absolute</altitudeMode>\n");
    printf("<coordinates>\n");
}

void printFinalTrackPoints(){
    printf("</coordinates>\n");
    printf("</LineString>\n");
    printf("</Placemark>\n");
}

void printFinal(){
    printf("</Document>\n");
    printf("</kml>\n");
}
