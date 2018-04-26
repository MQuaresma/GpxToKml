%option main
%x TRACKPOINTS TRACKPOINT DESCRIPTION WAYPOINT METADATA AUTHOR LINK COPYRIGHT BOUNDS

%{
void printHead();
void printFinal();
void printLine();
void printFinalTrackPoints();
char stackLink[15];
int linkP=0;
char *tmp;
int descTag=0;
%}

%%
\<gpx                                              {printHead();}
\<trk\>                                            {BEGIN TRACKPOINTS; printf("<Placemark>\n");}
\<\/gpx\>                                          {printFinal();}
\<wpt                                              {BEGIN WAYPOINT; printf("<Placemark>\n");}
\<metadata\>                                       {BEGIN METADATA;}

<METADATA>{
\<name\>(.*)?\<\/name\>                            {printf("%s\n",yytext);}
\<desc\>(.*)?/\<\/desc\>                           {if(descTag==0){printf("<description>\n");descTag=1;} printf("Desc: %s \n",yytext+6);}
\<copyright\>                                      {if(descTag==0){printf("<description>\n");descTag=1;} BEGIN COPYRIGHT; printf("Copyright: ");}
\<link                                             {if(descTag==0){printf("<description>\n");descTag=1;} BEGIN LINK; stackLink[linkP++]=METADATA; printf("Link: ");}
\<keywords\>(.*)?/\<\/keywords\>                   {if(descTag==0){printf("<description>\n");descTag=1;} printf("Keywords: %s \n",yytext+10);}
\<bounds                                           {if(descTag==0){printf("<description>\n");descTag=1;} BEGIN BOUNDS; printf("Bounds: ");}
\<time\>(.*)?/\<\/time\>                           {if(descTag==0){printf("<description>\n");descTag=1;} printf("Time: %s \n",yytext+6);}
\<author\>                                         {if(descTag==0){printf("<description>\n");descTag=1;} BEGIN AUTHOR; printf("Author: ");}
\<\/metadata\>                                     {BEGIN INITIAL; if(descTag){printf("</description>\n");descTag=0;}}
}

<AUTHOR>{
\<name\>(.*)?\<\/name\>                            {printf("Name: %s ",strndup(yytext+6,strlen(yytext+6)-7));}
\<email                                            {printf("Email: ");}
id=\"(.*)?/\"                                      {printf("Id: %s",yytext+4);}
domain=\"(.*)?/\"                                  {printf("Domain: %s",yytext+8);}
\<link                                             {BEGIN LINK; printf("Link: "); stackLink[linkP++]=AUTHOR;}
\<\/author\>                                       {BEGIN METADATA; printf("\n");}
}

<COPYRIGHT>{
author=\"(.*)?/\"                                  {printf("Author: %s ",yytext+8);}
\<year\>(.*)?/\<\/year\>                           {printf("Year: %s",yytext+6);}
\<license\>(.*)?/\<\/license\>                     {printf("License: %s",yytext+9);}
\<\/copyright\>                                    {BEGIN METADATA; printf("\n");}
}

<LINK>{
href=\"(.*)?/\"                                    {printf("%s ",yytext+6);}
\<text\>(.*)?/\<\/text\>                           {printf("Text: %s",yytext+6);}
\<type\>(.*)?/\<\/type\>                           {printf("Type: %s",yytext+6);}
\<\/link\>                                         {BEGIN stackLink[--linkP]; printf("\n");}
}

<BOUNDS>{
minlat=\"[-+]?[0-9]+(\.[0-9]+)?/\"                 {printf("MinLatitude: %s ",yytext+8);}
minlon=\"[-+]?[0-9]+(\.[0-9]+)?/\"                 {printf("MinLongitude: %s ",yytext+8);}
maxlat=\"[-+]?[0-9]+(\.[0-9]+)?/\"                 {printf("MaxLatitude: %s ",yytext+8);}
maxlon=\"[-+]?[0-9]+(\.[0-9]+)?/\"                 {printf("MaxLongitude: %s ",yytext+8);}
\/\>                                               {BEGIN METADATA; printf("\n");}
}


<WAYPOINT>{
\<name\>(.*)?\<\/name\>                            {printf("%s\n",yytext);}
\<desc\>(.*)?/\<\/desc\>                           {printf("<description>%s</description>\n",yytext+6);}
lat=\"[-+]?[0-9]+(\.[0-9]+)?/\"                    {tmp=strndup(yytext+5,strlen(yytext-5));}
lon=\"[-+]?[0-9]+(\.[0-9]+)?/\"                    {printf("<Point>\n<coordinates>%s,%s,",yytext+5,tmp);}
\<ele\>[-+]?[0-9]+(\.[0-9]+)?/\<\/ele\>            {printf("%s</coordinates>\n</Point>\n", yytext+5);}
\<\/wpt\>                                          {BEGIN INITIAL; printf("</Placemark>\n");}
}

<TRACKPOINTS>{
\<trkpt                                            {BEGIN TRACKPOINT;}
\<trkseg\>                                         {BEGIN TRACKPOINT; printLine();}
\<name\>(.*)?\<\/name\>                            {BEGIN DESCRIPTION; printf("%s\n",yytext); printf("<description>\n");} 
\<gpxtrkx:TrackStatsExtension(.*)?\>               {BEGIN DESCRIPTION; printf("<description>\n");}
\<\/trk\>                                          {BEGIN INITIAL; printFinalTrackPoints();}
}

<TRACKPOINT>{
lat=\"[-+]?[0-9]+(\.[0-9]+)?\"                     {tmp=strndup(yytext+5,strlen(yytext+5)-1);}
lon=\"[-+]?[0-9]+(\.[0-9]+)?\"                     {printf("%s,%s,",strndup(yytext+5,strlen(yytext+5)-1),tmp);}
\<ele\>[-+]?[0-9]+(\.[0-9]+)?\<\/ele\>             {printf("%s\n",strndup(yytext+5,strlen(yytext+5)-6)); BEGIN TRACKPOINTS;}
}

<DESCRIPTION>{
\<desc\>(.*)?/\<\/desc\>                           {printf("Desc:%s\n",yytext+6);}
\<type\>(.*)?/\<\/type\>                           {printf("Type:%s\n",yytext+6);}
\<gpxtrkx:Distance\>(.*)?/\<\/gpxtrkx:Distance\>   {printf("Distance: %s m\n",yytext+18);};
\<gpxtrkx:Ascent\>(.*)?/\<\/gpxtrkx:Ascent\>       {printf("D+: %s m\n",yytext+16);};
\<gpxtrkx:Descent\>(.*)?/\<\/gpxtrkx:Descent\>     {printf("D-: %s m\n",yytext+17);};
\<gpxtrkx:Calories\>(.*)?/\<\/gpxtrkx:Calories\>   {printf("Calories: %s\n",yytext+18);};
\<trkseg\>                                         {BEGIN TRACKPOINT; printf("</description>\n"); printLine();}
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
