package ose;

import ose.macros.GitCommit;

class Global
{
	public static var OSEV:String = '1.0';
	public static var OSEVersion:String = '${OSEV} (${GitCommit.getGitCommitHash()})${#if debug ' PROTOTYPE' #else '' #end}';
	public static var OSEWatermarkString:String = 'vs Sinco';
	public static var OSEWatermark:String = 'OSE 1.1\n$OSEWatermarkString $OSEVersion';
}
