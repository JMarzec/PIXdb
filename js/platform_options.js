function redirect(){

var groups=document.uploadform.technology.options.length;
var group=new Array(groups);
for (i=0; i<groups; i++){
group[i]=new Array();
}


group[0][0]=new Option("Platform*","0");

group[1][0]=new Option("cDNA Array hybridization","cDNA Array hybridization");
group[1][1]=new Option("Oligo MicroArray hybridization (Affymetrix) ","Oligo MicroArray hybridization (Affymetrix)");
group[1][2]=new Option("Oligo MicroArray hybridization (Agilent) ","Oligo MicroArray hybridization (Agilent)");
group[1][3]=new Option("Oligo MicroArray hybridization (Illumina) ","Oligo MicroArray hybridization (Illumina)");
group[1][4]=new Option("Oligo MicroArray hybridization (Operon) ","Oligo MicroArray hybridization (Operon)");
group[1][5]=new Option("PCR","PCR");
group[1][6]=new Option("Other","Other");

group[2][0]=new Option("Electrophoresis","Electrophoresis");
group[2][1]=new Option("Immunohistochemistry","Immunohistochemistry");
group[2][2]=new Option("Mass spectrometry","Mass spectrometry");
group[2][3]=new Option("Protein MicroArray hybridization","Protein MicroArray hybridization");
group[2][4]=new Option("Western blot","Western blot");
group[2][5]=new Option("Other","Other");

group[3][0]=new Option("Methylation MicroArray hybridization","Methylation MicroArray hybridization");
group[3][1]=new Option("Methylation-specific PCR (MSP)","Methylation-specific PCR (MSP)");
group[3][2]=new Option("Other","Other");

group[4][0]=new Option("miRNA Array hybridization","miRNA Array hybridization");
group[4][1]=new Option("PCR ","PCR");
group[4][2]=new Option("Other","Other");

group[5][0]=new Option("Literature analysis","Literature analysis");
group[5][1]=new Option("Reanalysis:Transcriptomic experimental data","Reanalysis:Transcriptomic experimental data");
group[5][2]=new Option("Reanalysis:Proteomic experimental data","Reanalysis:Proteomic experimental data");
group[5][3]=new Option("Reanalysis:Methylomic experimental data","Reanalysis:Methylomic experimental data");
group[5][4]=new Option("Reanalysis:miRNA experimental data","Reanalysis:miRNA experimental data");
group[5][5]=new Option("Other","Other");

var temp=document.uploadform.platform;

for (m=temp.options.length-1;m>0;m--){
temp.options[m]=null;	
}
var x = document.uploadform.technology;
for (i=0;i<group[x.selectedIndex].length;i++){
temp.options[i]=new Option(group[x.selectedIndex][i].text,group[x.selectedIndex][i].value);
}
temp.options[0].selected=true;
}

