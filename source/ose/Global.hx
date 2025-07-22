package ose;

import ose.macros.GitCommit;

class Global
{
	public static var OSEV:String = '1.1';
	public static var OSEVersion:String = '${OSEV} (${GitCommit.getGitCommitHash()})${#if debug ' PROTOTYPE' #else '' #end}';
	public static var OSEWatermarkString:String = 'OSE';
	public static var OSEWatermark:String = '$OSEWatermarkString $OSEVersion';
}
