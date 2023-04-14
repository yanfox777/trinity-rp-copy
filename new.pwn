//=============================[ ������� ]=============================//
#include <a_samp>
#include <a_mysql>
#include <core>
#include <float>
#include <streamer>
#include <Pawn.CMD>
#include <sscanf2>
#include <YSF>
#include <md5>
#include <rustext>
#include <foreach>
#include <dynamicmaps>
#include ../library/Includes/a_vehiclenames
//=============================[ ��������� ���� ]=============================//
//===[ ��������� ���� (������ � �������) ]===//
#define SERVER_NAME			"Trinity"
#define SERVER_URL			"www.gta-trinity.ru"
#define SERVER_NUMBER		"1"
#define SERVER_VERSION		"0.4"
#define SERVER_LANGUAGE		"Russian"
//===[ ��������� ���� (��������� ����������� � ��) ]===//
#define MYSQL_HOST			"127.0.0.1"
#define MYSQL_USER      	"root"
#define MYSQL_DB        	"trinity"
#define MYSQL_PASSWORD  	""
//=============================[ ���������� ]=============================//
//===[ ���������� (TextDraw) ]===//
new Text:Select_City;//��������� ���������� ������ ��� �����������
new Text:Select_TD[7];//���������� ������
new Text:Logo;//�������
new Text:CarName_Global[2];//�������� ���� ����� ����� �������
new Text:GreenZone_TD;//������� ����
new Text:Black_Background[2];//������ ������ ������ � �����
new PlayerText:Time_TD[MAX_PLAYERS][2];//����� ������� ��� ������
new PlayerText:CarName_Player[MAX_PLAYERS];//�������� ���� ����� ����� �������
new PlayerText:GiveMoney_Player[MAX_PLAYERS];//������ ����� ������
new PlayerText: Background_TD[MAX_PLAYERS];
//===[ ���������� (Other) ]===//
new Float:RandomCameraRequestClass[9][10] =//������� ��������� ����� ��� ������� �� ������ <<<, >>> � �.�
{
	{404.5463, -1898.4084, 1.0087, 539.2126, -1870.7793, 8.7474, 388.4152, -1898.5267, -2.7097, 281.5944},
	{328.3336, -1517.8082, 72.3909, 462.9807, -1570.3113, 39.3040, 304.3750, -1535.4847, 36.0391, 0.0000},
	{-1698.4014, 801.5182, 60.0339, -1762.9686, 850.9774, 33.5006, -1683.3479, 812.9704, 53.1904, 76.2890},
	{-1802.7817, -2283.4885, 66.8412, -1795.1852, -2424.5564, 54.9615, -1802.4427, -2275.8540, 57.4756, 177.9034},
	{-1698.4014, 801.5182, 60.0339, -1762.9686, 850.9774, 33.5006, -1683.3479, 812.9704, 53.1904, 76.2890},
	{328.3336, -1517.8082, 72.3909, 462.9807, -1570.3113, 39.3040, 304.3750, -1535.4847, 36.0391, 0.0000},
	{-281.7087, 1345.1073, 84.1129, -159.2082, 1157.7959, 25.5689, -290.2365, 1356.0061, 67.0294, 226.0638},
	{2093.7422, 1174.9044, 23.1826, 2033.4520, 1317.3606, 15.1298, 2094.1260, 1169.5430, 14.5625, 22.8758},
	{-2680.4614, -295.5879, 40.2937, -2734.5061, -136.1472, 10.7261, -2682.4434, -307.8390, 33.7551, 0.2651}
};

enum cityinfo
{
	CityName[30],//�������� ������
	CityHour,//����� � ������
	Float:CityCamPos[6],//������� ������ ��� ������������
	Float:CityCamPlayerPos[3]//������� ������ ��� ���������������� � ����
}
new CityInfo[3][cityinfo] =//����� ������ ��� �����������
{
	{"~y~US of Arcadia", 7, {1757.4297, -1139.1707, 85.4141, 1617.2888, -1065.3325, 85.4141}, {1757.4297,-1139.1707,105.4141}},
	{"~g~Aurora Federation", 8, {-1340.3208, 737.4349, 45.4765, -1554.3126, 741.5575, 91.1096}, {-1340.3208,737.4349,65.4765}},
	{"~r~Respublica Constantia", 0, {2115.5767, 2153.9744, 13.4077, 2212.3984, 2133.8354, 55.3012}, {2115.5767,2153.9744,33.4077}}
};

new RegSkins[][] =//����� ��� �����������
{
	{233, 151, 214, 150, 41, 131, 40, 148, 65, 9, 13, 76, 169, 225, 224, 263},//�������
    {188, 59, 101, 202, 47, 30, 48, 184, 7, 19, 21, 28, 210, 229, 57, 60}//�������
};

new ActorNames[][] =
{
	"Francesco Schettino",
	"Ralf Sikorsky",
	"Francua Lemark",
	"Richard Beckwith",
	"Sallie Beckwith",
	"Karl Behr",
	"������������� ��������"
};
	
enum pinfo//������ ������
{
	tRegPassword[16],//������ ��� �����������
	tRegSex,//��� ��� �����������
	tRegReferal[20],//������� ��� �����������
	tRegCity,//����� ��� �����������
	tRegSkin,//���� ��� �����������
	tLoginAttempts,//������� ��� �����������
	tIP[16],//IP ������
	tGPS,//������� �� GPS
	tSelectedDynamicActor,//��������� ���
	tSelectedTD,//��������� ��� ����������
	tTimer,//������ ������
	tBackgroundBox,//������ ���������� ������ ������
	tBackgroundTimer,//������ ���������� ������ ������
	tSelectSkinTimer,//������ ����� �������� ������ �����
	tLoginTime,//����� �� �����������
	tBrightnessColor,//������� ����������
	tBikeRent,//������������ �����
	tBikeRentTime,//����� �� �������� ������
	tAFK,//� ��� �� �����
	bool:tGreenZone,//� ������� ���� �� �����
    tGreenZoneTime,//����� �������� ������������ ����� ������� ����
    Text3D:tDescriptionLabel,//3� ����� �������� ���������
    bool:tDescriptionUpdate,//���������� 3� ������ �������� ���������
    tCameraObject,//������ ������
	tCameraStage,//���� ������
	tPlaneObject,//������ �������� ��� �����������
	tFreezeTime,//����� �������� ��������� ������
	bool:tChecked,//������ �� �������� �������� ������ � ���� ������
	bool:tLogged,//������������� �� �����
	bool:tSpawned,//��������� �� �����
	tPTJob,//������ ������ (������ ��� ��������)
	pID,//�� ������
	pName[MAX_PLAYER_NAME],//��� ������
	pPassword[32 + 1],//������ ������
	pLevel,//������� ������
	pSex,//��� ������
	pCity,//����� ������
	pSkin,//���� ������
	pMoney,//������ ������
	pDescription[120 + 1],//�������� ������
	pPTJobCount
}
new pInfo[MAX_PLAYERS][pinfo];//���������� ������� ������

enum ginfo//������ ���������� ����������
{
	bool:tPayDay[24],//����������, ��� �� ������ � ������������ ����� (������� ��� ����, ����� �� ���� ��������� ������ ���� ������ ��������� 0 �������)
	gMySQL,//���������� ��������� �� MySQL �����������
	gString[4096],//���������� ������ (��� ���� ����� �� �������� ����)
	gDynamicActor[MAX_ACTORS],//��� ������
	bool:gDynamicActorTalk[MAX_ACTORS]//����� �� �������� � ������� (true �� | false ���)
}
new gInfo[ginfo];//���������� ������� ���������� ����������

enum bikerent
{
	Float:RentPos[3],//������� ������
	Float:ArentPosTP[4]//������� �� ��� ������
}
new BikeRent[][bikerent] =//������ �������
{
	{{1630.3879, -2260.1016, 12.4941}, {1626.8546, -2261.1504, 13.0838, 90.0}},//LS Spawn
	{{2595.3804, -2214.4001, 12.5469}, {2597.2607,-2222.9126,12.9399, 87.2859}},//������ �������� LS
	{{-1451.1064, -271.2626, 13.1484}, {-1455.3387, -272.7280, 13.7350, 244.7559}},//SF Spawn
	{{-1903.7822, -1699.1329, 20.7500}, {-1906.0851, -1703.5929, 21.3374, 161.0850}},//������ ������� SF
	{{1703.4656, 1392.9520, 9.6866}, {1708.5726, 1388.7473, 10.2336, 313.9955}},//LV Spawn
	{{2494.7214, 1944.5438, 9.8203}, {2486.6423, 1945.8352, 9.7466, 359.3986}}//������ ��������� LV
};

enum busstop
{
	City,
	Float:MiniMapPos[4],
	DynamicMap:MiniMapObject,
	Point:MiniMapPosObject[2]
}
new BusStop[][busstop] =//���������� ���������
{
    //LS ��������
	{0, {1665.764526, -2245.958984, 14.168700, 270.0}},
    //LS �������� ������
	{0, {2562.261963, -2239.712646, 14.303400, 0.0}},
	//SF ��������
	{1, {-1398.946777, -314.338013, 14.751200, 270.0}},
	//SF ������
	{1, {-1887.928955, -1747.380737, 22.312599, 180.0}},
	//LV �����
	{2, {1723.729004, 1534.459595, 11.591400, 0.0}},
	//LV �������������
	{2, {2484.060059, 1960.976685, 11.303800, 360.0}}
};

enum greenzone
{
	Float:gPos[4],
	gWorld,
	gInterior,
	gZone
}
new GreenZone[][greenzone] =//������� ����
{
	{{1553.0988, -2170.8477, 1809.9324, -2405.7610}, 0, 0},//Spawn LS
	{{2538.1594, -2286.7290, 2678.9619, -2183.4263}, 0, 0},//������ �������� LS
	{{-1142.9832, -486.3508, -1797.0763, -232.1729}, 0, 0},//Spawn SF
	{{-2027.7865, -1521.7968, -1644.4197, -1674.6505}, 0, 0},//������ ������� SF
	{{1730.9215, 1284.1443, 1600.2827, 1608.5275}, 0, 0},//Spawn LV
	{{2505.8892, 1967.5350, 2405.5027, 1874.7389}, 0, 0}//������ ������� LV
};


new BrightnessColors[][] =//����� ������� ��� �����������
{
	{0xFFFFFF00, 0x00000000},
	{0xFFFFFF11, 0x00000011},
	{0xFFFFFF22, 0x00000022},
	{0xFFFFFF33, 0x00000033},
	{0xFFFFFF44, 0x00000044},
	{0xFFFFFF55, 0x00000055},
	{0xFFFFFF66, 0x00000066},
	{0xFFFFFF77, 0x00000077},
	{0xFFFFFF88, 0x00000088},
	{0xFFFFFF99, 0x00000099},
	{0xFFFFFFAA, 0x000000AA},
	{0xFFFFFFBB, 0x000000BB},
	{0xFFFFFFCC, 0x000000CC},
	{0xFFFFFFDD, 0x000000DD},
	{0xFFFFFFEE, 0x000000EE},
	{0xFFFFFFFF, 0x000000FF},
	{0xFFFFFFEE, 0x000000EE},
	{0xFFFFFFDD, 0x000000DD},
	{0xFFFFFFCC, 0x000000CC},
	{0xFFFFFFBB, 0x000000BB},
	{0xFFFFFFAA, 0x000000AA},
	{0xFFFFFF99, 0x00000099},
	{0xFFFFFF88, 0x00000088},
	{0xFFFFFF77, 0x00000077},
	{0xFFFFFF66, 0x00000066},
	{0xFFFFFF55, 0x00000055},
	{0xFFFFFF44, 0x00000044},
	{0xFFFFFF33, 0x00000033},
	{0xFFFFFF22, 0x00000022},
	{0xFFFFFF11, 0x00000011},
	{0xFFFFFF00, 0x00000000}
};

enum pickup
{
	pModel,//������ ������
	pText[32],//����� ������ (-, ���� �� ����� ��������� �����)
	Float:pPos[3],//������� ������
	pVirtualWorld,//����������� ��� ������
	pInterior,//�������� ������
	Float:pPosEnter[4],//�������, ���� ������������� �����
	pVirtualWorldEnter,//����������� ���, ���� ������������� �����
	pInteriorEnter,//��������, ���� ������������� �����
	pID//������������� ������
}
new Pickup[][pickup] =//������, ���� ����� ��� 3� ������, �� ����� ��������� "-"
{
	//������ �������� LS
	{1318, "����������", {2589.9509, -2239.7490, 13.5390}, 0, 0, {-2206.4502, 405.7142, 2166.2390, 274.1064}, 1, 17},//����������
	{1318, "�����", {2604.6230, -2238.1990, 13.5470}, 0, 0, {-2207.1367, 413.5559, 2166.2390, 279.2227}, 2, 17},//�����
	{19198, "-", {-2207.5020, 403.8684, 2166.5894}, 1, 17, {2590.3879, -2236.7810, 13.5392, 351.6250}, 0, 0},//����� �� ����������
	{19198, "-", {-2207.5896, 412.1147, 2166.5894}, 2, 17, {2607.6160, -2238.4060, 13.5392, 266.0520}, 0, 0},//����� �� �����
	//������ ������� SF
	{1318, "����������", {-1837.7490, -1647.7460, 21.7560}, 0, 0, {-2206.4502, 405.7142, 2166.2390, 274.1064}, 3, 17},//����������
	{1318, "�����", {-1826.2610, -1639.8510, 21.7500}, 0, 0, {-2207.1367, 413.5559, 2166.2390, 279.2227}, 4, 17},//�����
	{19198, "-", {-2207.5020, 403.8684, 2166.5894}, 3, 17, {-1834.7791, -1647.3210, 21.7500, 278.1490}, 0, 0},//����� �� ����������
	{19198, "-", {-2207.5896, 412.1147, 2166.5894}, 4, 17, {-1826.4440, -1642.8459, 21.7500, 176.4930}, 0, 0},//����� �� �����
	//������ ��������� LV
	{1318, "����������", {2481.2900, 1958.3840, 10.6360}, 0, 0, {-2206.4502, 405.7142, 2166.2390, 274.1064}, 5, 17},//����������
	{1318, "�����", {2441.5339, 1954.7220, 10.8050}, 0, 0, {-2207.1367, 413.5559, 2166.2390, 279.2227}, 6, 17},//�����
	{19198, "-", {-2207.5020, 403.8684, 2166.5894}, 5, 17, {2477.8081, 1957.0229, 10.5827, 91.4110}, 0, 0},//����� �� ����������
	{19198, "-", {-2207.5896, 412.1147, 2166.5894}, 6, 17, {2444.5320, 1954.6080, 10.7648, 267.8200}, 0, 0}//����� �� �����
};

enum ptjob
{
	Float:jPos[3],//������� ������ (����� ���������� ��� ����������, � ������ ���� �� 100� ������)
	jLockerRoomVirtualWorld,//����������� ��� ����������
	jCashVirtualWorld,//����������� ��� �����
	jLockerRoomPickupID,//������������� ������ ����������
	jCashPickupID//������������� ������ �����
}
new PTJob[][ptjob] =//������ ��� ��������
{
	//������ �������� LS (0)
	{{2604.6230, -2238.1990, 13.5470}, 1, 2},
	//������ ������� SF (1)
	{{-1826.2610, -1639.8510, 21.7500}, 3, 4},
	//������ ��������� LV (2)
	{{2441.5339, 1954.7220, 10.8050}, 5, 6}
};
new PTJobCP[6];
new engine, lights, alarm, doors, bonnet, boot, objective;//��������� ����
//=============================[ �������/������� ]=============================//
#define PN(%0) pInfo[%0][pName]
#define public:%0(%1) forward%0(%1); public%0(%1)
#define void%0[%1]; static %0[%1]; %0[0] = EOS;
public: PlayKick(playerid) Kick(playerid);
#define Kick(%0) SetTimerEx("PlayKick", 500, false, "d", %0)
#define COLOR_GREY 0xAFAFAFFF
#define COLOR_GREEN 0x34C924FF
#define COLOR_PURPLE 0xC2A2DAFF
#define COLOR_YELLOW 0xFFCC00FF
#define COLOR_LIGHTBLUE 0x00BFFFFF
#define COLOR_RED 0xFF6347FF
#define SCM	SendClientMessage
#define SCMf SendClientMessagef
#define SCMAllf SendClientMessageToAllf
//=============================[ ������� ]=============================//
main(){}
public OnPlayerConnect(playerid)
{
	if(IsPlayerNPC(playerid)) return 1;
	
	if(mysql_errno() != 0 && mysql_errno() != 1146)
	{
		SPD(playerid, 0, DIALOG_STYLE_MSGBOX, "{34C924}"SERVER_NAME" GTA", "{FFFFFF}����������� ������. �� ������� ��������� ����� �������� � ���� ������", "X", "");
		Kick(playerid);
		return 0;
	}

	NullPlayer(playerid);//��������� ������
	GetPlayerName(playerid, pInfo[playerid][pName], 25);//������ ���� � ������
	if(!IsRPNick(PN(playerid)))
	{
		SPD(playerid, 6, DIALOG_STYLE_MSGBOX, "{34C924}�� �� ������ ������ ���� � ���� �����", "{ffffff}������ ������ ���� �� ������������� �������� roleplay ���� �� ����� �������.\n\n���� �� ������ ����� � ��� �� ������, ��������� ��������� ������ � ����� ����:\n\n{fbec5d}��� ����� �������� ������ �� ���������� ����, ����������� �������� �������������", "X", "");
		Kick(playerid);
		return 0;
	}
	
	TextDrawShowForPlayer(playerid, Logo);//����������� ��������
	
	CreatePlayerTextDraws(playerid);//�������� ����������� ��� ������
	RemoveObjectForPlayer(playerid);//�������� �������� ��� ������
	ResetDynamicCPs(playerid);//�������� ��������� ��� ������
	
	format(gInfo[gString], 145, "SELECT * FROM `accounts` WHERE `NickName` = '%s' LIMIT 1", PN(playerid));
	mysql_tquery(gInfo[gMySQL], gInfo[gString], "CheckPlayerAccount", "i", playerid);//�������� ��������������� �� �����

	for(new i; i < 30; i++) SCM(playerid, COLOR_GREY, "�");
	
	pInfo[playerid][tTimer] = SetTimerEx("PlayerTimer", 1000, true, "i", playerid);//������ ������
	return 1;
}
public OnPlayerDisconnect(playerid, reason)
{
	if(pInfo[playerid][tBikeRent] != -1) DestroyVehicle(pInfo[playerid][tBikeRent]);
	if(pInfo[playerid][tCameraObject] != -1) DestroyPlayerObject(playerid, pInfo[playerid][tCameraObject]);
	if(pInfo[playerid][tPlaneObject] != -1) DestroyPlayerObject(playerid, pInfo[playerid][tPlaneObject]);
	if(strlen(pInfo[playerid][pDescription])) DestroyDynamic3DTextLabel(pInfo[playerid][tDescriptionLabel]);
	KillTimer(pInfo[playerid][tTimer]);//������ ������
	if(pInfo[playerid][tBackgroundTimer]) KillTimer(pInfo[playerid][tBackgroundTimer]);
	if(pInfo[playerid][tSelectSkinTimer]) KillTimer(pInfo[playerid][tSelectSkinTimer]);
	NullPlayer(playerid);//��������� ������� ������
	for(new i; i < 8; i++) Streamer_DestroyAllVisibleItems(playerid, i);
}
public: CheckPlayerAccount(playerid)
{
	if(IsPlayerNPC(playerid)) return 1;
	pInfo[playerid][tLoginTime] = gettime() + 90;
	pInfo[playerid][tChecked] = true;
    PlayerPlaySound(playerid, 1187, 0.0, 0.0, 0.0);
	SetPlayerVirtualWorld(playerid, playerid + 50);//����������� ��� ��� ���� ����� ������ �� ������ ���� ����� ��� �����������/�����������
	SCMf(playerid, COLOR_GREY, "{F5DEB3}����� ����������, %s. ��������, ��� �� ������ ��������� ����� � ���.", PN(playerid));
	
	//���� ����� �� ������ � ����
	if(!cache_get_row_count(gInfo[gMySQL]))
	{
		pInfo[playerid][tLoginTime] = gettime() + 300;
		SPD(playerid, 1, DIALOG_STYLE_INPUT, "{34C924}"SERVER_NAME" GTA", "\n{FFFFFF}������������ ��� �� ����� �������. ��� ��� �������� � �������� ��� �����������.\n\n ������ ��� ���������� ��������� ������ � ������ ��� � ����, ����������� ����:\n ", "�����", "�����");
		return 1;
	}

    pInfo[playerid][pID] = cache_get_field_content_int(0, "ID", gInfo[gMySQL]);//������ ��� ������ � ������
	cache_get_field_content(0, "Password", pInfo[playerid][pPassword], gInfo[gMySQL]);//������ ������ � ������
 	SPD(playerid, 2, DIALOG_STYLE_PASSWORD, "{34C924}"SERVER_NAME" GTA", "{FFFFFF}������������ ��� �� ����� �������. ������� � ������ ����� ��� ���-�� ���������������.\n���� ��� ��� ������� � �� ������ ������ �� ����, ������� ��� � ����, ������������� ����.\n\n���� �� �� ��������� ���������� ����� ��������, �� ������ ����� �� ���� �������� {abcdef}/q{ffffff},\n�������� ��� � ���� sa-mp ������� � ���������������� ����� ������� �� ����� �������.\n\n���� ��� ��� ������� � �� ������ ������, ��� ������� ��� � �������� �������� email �����\n������������� ���, �� ������ ����� � ���� ������ ������, ����� {fbec5d}HELP{ffffff} � ���� ��� �����.\n\n{FF8282}�������, ��� ��� ����� ������������� ������ ����� 5-� ���, ��� IP ����� ����� �������.", "�����", "");
	return 1;
}
public: OnPlayerRegisterMysql(playerid)
{
    pInfo[playerid][pID] = cache_insert_id(gInfo[gMySQL]);
	OnPlayerLogin(playerid);
    return 1;
}
public: OnPlayerLoginMysql(playerid)
{
    pInfo[playerid][pID] = cache_get_field_content_int(0, "ID", gInfo[gMySQL]);
    pInfo[playerid][pLevel] = cache_get_field_content_int(0, "Level", gInfo[gMySQL]);
    pInfo[playerid][pSex] = cache_get_field_content_int(0, "Sex", gInfo[gMySQL]);
    pInfo[playerid][pSkin] = cache_get_field_content_int(0, "Skin", gInfo[gMySQL]);
    pInfo[playerid][pCity] = cache_get_field_content_int(0, "City", gInfo[gMySQL]);
    pInfo[playerid][pMoney] = cache_get_field_content_int(0, "Money", gInfo[gMySQL]);
    cache_get_field_content(0, "Description", pInfo[playerid][pDescription], gInfo[gMySQL]);
    pInfo[playerid][pPTJobCount] = cache_get_field_content_int(0, "PTJobCount", gInfo[gMySQL]);
    PlayerTextDrawSetString(playerid, Time_TD[playerid][1], GetTime(1));
    PlayerTextDrawSetString(playerid, Time_TD[playerid][0], GetTime(2));
	for(new i; i < 2; i++) PlayerTextDrawShow(playerid, Time_TD[playerid][i]);
	new temp_ip[16];
	GetPlayerIp(playerid, temp_ip, sizeof(temp_ip));
	SetString(pInfo[playerid][tIP], temp_ip);
    pInfo[playerid][tLogged] = true;
	SetPlayerScore(playerid, pInfo[playerid][pLevel]);
	SetPlayerMoney(playerid, pInfo[playerid][pMoney]);
    PlayerSpawn(playerid);
	if(strlen(pInfo[playerid][pDescription])) SCMf(playerid, 0xF5DEB3FF, "���� ��������: {FFFFFF}%s", pInfo[playerid][pDescription]);
    return 1;
}
public: ChangeSkinAnim(playerid, type)
{
	switch(type)
	{
		case 0:
		{
			ApplyAnimation(playerid, "CLOTHES", "CLO_Pose_Loop", 4.1, 1, 0, 0, 1, 1);
			if(pInfo[playerid][tSelectSkinTimer])
			{
				KillTimer(pInfo[playerid][tSelectSkinTimer]);
				pInfo[playerid][tSelectSkinTimer] = 0;
			}
		}
		case 1:
		{
		    new anims[][] = {"CLO_Pose_Legs", "CLO_Pose_Torso", "CLO_Pose_Hat", "CLO_Pose_Shoes"};
			ApplyAnimation(playerid, "CLOTHES", anims[random(sizeof(anims))], 4.1, 0, 0, 0, 1, 1);
			if(pInfo[playerid][tSelectSkinTimer]) KillTimer(pInfo[playerid][tSelectSkinTimer]);
			pInfo[playerid][tSelectSkinTimer] = SetTimerEx("ChangeSkinAnim", 4000, false, "ii", playerid, 0);
		}
	}
	return 1;
}
public OnPlayerRequestClass(playerid,classid)
{
	SetSpawnInfo(playerid, 255, 0, 0, 10, 0, 0, 0, 0, 0, 0, 0, 0);
	if(IsPlayerNPC(playerid)) return 1;
	if(pInfo[playerid][tLogged]) return PlayerSpawn(playerid);
	SetPlayerRandomCamera(playerid);
    return 0;
}
public OnPlayerRequestSpawn(playerid)
{
	if(IsPlayerNPC(playerid)) return 1;
	if(!pInfo[playerid][tLogged]) return 0;
	return 1;
}
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	void inputtextsave[320];

	mysql_escape_string(inputtext, inputtextsave);

	for(new i; i < strlen(inputtextsave); i++)
	{
		switch(inputtextsave[i])
		{
			case 'A'..'Z', 'a'..'z', '�'..'�', '�'..'�', '0'..'9', ' ', '>', '<', '(', ')', '/', '+', '-','_', '?', '!', '.', ',', '@': continue;
			default: inputtextsave[i] = ' ';
		}
	}
	
	SetPVarInt(playerid, "DialogID", -1);
	SetPVarInt(playerid, "PickupFlood", gettime() + 2);
	new uncorrect;
	for(new i; i < strlen(inputtextsave); i++)//������ �� ����� ������� � �.�
	{
		if(inputtextsave[i] == '%')
		{
			inputtextsave[i] = '#';
			uncorrect = 1;
		}
		else if(inputtextsave[i] == '\\')
		{
			inputtextsave[i] = '#';
			uncorrect = 1;
		}
		else if(inputtextsave[i] == '{' && inputtextsave[i+7] == '}')
		{
			strdel(inputtextsave, i, i+8);
			uncorrect = 1;
		}
	}
	switch(dialogid)
	{
	    case 1:
	    {
	        if(!response)
	        {
	            SCM(playerid, 0xF5DEB3FF, "�� �������, �� �������� ������� ��� ����� �� ����� �������.");
	            SetPlayerRandomCamera(playerid);
	            Kick(playerid);
	            return 1;
	        }
	        if(!strlen(inputtextsave)) return SPD(playerid, 1, DIALOG_STYLE_INPUT, "{34C924}"SERVER_NAME" GTA", "\n{FFFFFF}������������ ��� �� ����� �������. ��� ��� �������� � �������� ��� �����������.\n\n ������ ��� ���������� ��������� ������ � ������ ��� � ����, ����������� ����:\n ", "�����", "�����");
			if(strlen(inputtextsave) > 16)
			{
				SCM(playerid, COLOR_GREY, "������������ ����� ������ {33aa33}16{afafaf} ��������, ���������� ������ ��������.");
				SPD(playerid, 1, DIALOG_STYLE_INPUT, "{34C924}"SERVER_NAME" GTA", "\n{FFFFFF}������������ ��� �� ����� �������. ��� ��� �������� � �������� ��� �����������.\n\n ������ ��� ���������� ��������� ������ � ������ ��� � ����, ����������� ����:\n ", "�����", "�����");
				return 1;
			}
			if(uncorrect || FindSymbol(inputtextsave, ' '))
			{
				SCM(playerid, COLOR_GREY, "{F5DEB3}������ ����� �������� ������ �� ���������� ��� ������� ���� � ����.");
				SPD(playerid, 1, DIALOG_STYLE_INPUT, "{34C924}"SERVER_NAME" GTA", "\n{FFFFFF}������������ ��� �� ����� �������. ��� ��� �������� � �������� ��� �����������.\n\n ������ ��� ���������� ��������� ������ � ������ ��� � ����, ����������� ����:\n ", "�����", "�����");
				return 1;
			}
			new hour, minute;
			gettime(hour, minute, _);
			SetPlayerTime(playerid, hour, minute);
			SPD(playerid, 3, DIALOG_STYLE_MSGBOX, "{34C924}"SERVER_NAME" GTA", "{FFFFFF}��������� ����� ����� ����� ���� ������ ���������", "�������", "�������");
			SetString(pInfo[playerid][tRegPassword],inputtextsave);
	    }
	    case 2:
	    {
	        if(!response || !strlen(inputtextsave)) return SPD(playerid, 2, DIALOG_STYLE_PASSWORD, "{34C924}"SERVER_NAME" GTA", "{FFFFFF}������������ ��� �� ����� �������. ������� � ������ ����� ��� ���-�� ���������������.\n���� ��� ��� ������� � �� ������ ������ �� ����, ������� ��� � ����, ������������� ����.\n\n���� �� �� ��������� ���������� ����� ��������, �� ������ ����� �� ���� �������� {abcdef}/q{ffffff},\n�������� ��� � ���� sa-mp ������� � ���������������� ����� ������� �� ����� �������.\n\n���� ��� ��� ������� � �� ������ ������, ��� ������� ��� � �������� �������� email �����\n������������� ���, �� ������ ����� � ���� ������ ������, ����� {fbec5d}HELP{ffffff} � ���� ��� �����.\n\n{FF8282}�������, ��� ��� ����� ������������� ������ ����� 5-� ���, ��� IP ����� ����� �������.", "�����", "");
			if(FindSymbol(inputtextsave, ' ')) return SPD(playerid, 5, DIALOG_STYLE_MSGBOX, " ", "{afafaf}������ ����� �������� ������ �� ��������� � ������������� �������� � ����.", "X", "");
			if(strlen(inputtextsave) > 16) return SPD(playerid, 5, DIALOG_STYLE_MSGBOX, " ", "{afafaf}������������ ����� ������ {33aa33}16{afafaf} ��������.", "X", "");
			if(!GetString(pInfo[playerid][pPassword], MD5_Hash(inputtextsave), true))
			{
			    pInfo[playerid][tLoginAttempts]--;
			    if(!pInfo[playerid][tLoginAttempts])
			    {
					SCM(playerid, 0xD8A903FF, "�� ��������� ���������� ����� ������� ����� � �������. ��� IP ����� ������������ � ����� ������������.");
					SCM(playerid, 0xD8A903FF, "���������� ����� ������������� ����� ����� {ffffff}10{D8A903} �����, � �� ������� ���������� ���� ���� �� ����� �������.");
                	TogglePlayerControllable(playerid, false);
					SetPlayerPos(playerid, 1410.9698,-1625.3530,43.0128);
					SetPlayerFacingAngle(playerid, 214.6142);
					SetPlayerCameraPos(playerid, 1422.7959, -1631.9661, 50.4452);
					SetPlayerCameraLookAt(playerid, 1495.0242, -1656.5164, 30.8696);
					Kick(playerid);
			        return 1;
			    }
			    format(gInfo[gString], 200, "{afafaf}�� ����� ������������ ������. �������� {FF8282}%d{afafaf} �������.",pInfo[playerid][tLoginAttempts]);
			    SPD(playerid, 5, DIALOG_STYLE_MSGBOX, " ", gInfo[gString], "X", "");
			    return 1;
			}
			SCM(playerid, COLOR_GREY, "{FFFFFF}� ������������, �� ������� ����� � ���� �������.");
			OnPlayerLogin(playerid);
	    }
	    case 3:
		{
   			SPD(playerid, 630, DIALOG_STYLE_LIST, "{34C924}��� �� ������ � ����� �������?", "� �� ���� ��� �� ���� ��������\n������� �� YouTube\n������� ���������\n������� � ������������\n������� � ������ ������\n����� ������ �� ������� hosted\n� ����� �� ������ ��������\n��� �� ������ ��� ������� �� �������\n����� �������� ��� � ���� ������", "�����", "");
			pInfo[playerid][tRegSex] = response;
		}
		case 5: SPD(playerid, 2, DIALOG_STYLE_PASSWORD, "{34C924}"SERVER_NAME" GTA", "{FFFFFF}������������ ��� �� ����� �������. ������� � ������ ����� ��� ���-�� ���������������.\n���� ��� ��� ������� � �� ������ ������ �� ����, ������� ��� � ����, ������������� ����.\n\n���� �� �� ��������� ���������� ����� ��������, �� ������ ����� �� ���� �������� {abcdef}/q{ffffff},\n�������� ��� � ���� sa-mp ������� � ���������������� ����� ������� �� ����� �������.\n\n���� ��� ��� ������� � �� ������ ������, ��� ������� ��� � �������� �������� email �����\n������������� ���, �� ������ ����� � ���� ������ ������, ����� {fbec5d}HELP{ffffff} � ���� ��� �����.\n\n{FF8282}�������, ��� ��� ����� ������������� ������ ����� 5-� ���, ��� IP ����� ����� �������.", "�����", "");
		case 68:
		{
			new city = pInfo[playerid][pCity];
			ApplyDynamicActorAnimation(gInfo[gDynamicActor][city], "ON_LOOKERS", "wave_loop", 4.0, 0, 0, 0, 0, 0);
			ApplyAnimation(playerid, "PED", "roadcross_gang", 4.1, 1, 0, 0, 0, 0);
			SetCameraToDynamicActor(playerid, gInfo[gDynamicActor][city], 5);
			
		    if(city == 0) SCMf(playerid, COLOR_LIGHTBLUE, "Francesco Schettino �������: ��, %s, ������� �� ���. � ���� ���� ��� ���� ���������� �����������.", PN(playerid));
		    else if(city == 1) SCMf(playerid, COLOR_LIGHTBLUE, "Ralf Sikorsky �������: ��, %s, ������� �� ���. � ���� ���� ��� ���� ���������� �����������.", PN(playerid));
		    else if(city == 2) SCMf(playerid, COLOR_LIGHTBLUE, "Francua Lemark �������: ��, %s, ������� �� ���. � ���� ���� ��� ���� ���������� �����������.", PN(playerid));
		
		    SPD(playerid, 69, DIALOG_STYLE_MSGBOX, "{fbec5d}����������� ���� ������ ������!", "{ffffff}����� ���� ����� {abcdef}NPC{ffffff}, ������� ������� ��� ���������� ����� �� ������ �����.\n������ ��������� � ���� ������� � �������� � ������ ��� ������ ������� {33aa33}/talk{ffffff}.", "X", "");
		}
		case 69, 46: EndTalkDynamicActor(playerid);
		case 202:
		{
		    if(!response) return DeletePVar(playerid, "PTJobID");
		    PTJobDialogStarted(playerid, GetPVarInt(playerid, "PTJobID"));
		}
		case 203:
		{
		    if(!response) return SPD(playerid, 44, DIALOG_STYLE_MSGBOX, " ", "{9ACD32}������: ������, ������ ���������� ������.", "X", "");
		    PTJobDialogEnded(playerid);
		}
		case 630:
		{
		    if(!response) return SPD(playerid, 630, DIALOG_STYLE_LIST, "{34C924}��� �� ������ � ����� �������?", "� �� ���� ��� �� ���� ��������\n������� �� YouTube\n������� ���������\n������� � ������������\n������� � ������ ������\n����� ������ �� ������� hosted\n� ����� �� ������ ��������\n��� �� ������ ��� ������� �� �������\n����� �������� ��� � ���� ������", "�����", "");
		    SPD(playerid, 631, DIALOG_STYLE_INPUT, "{34C924}������� ��� ������������� ��� ������", "{ffffff}����� �� ������ ������� ��� ������, ������� ��������� ��� �� ������. ����� ����, ��� �� ��������� {fbec5d}24{ffffff} ����, �� ������� {33aa33}50000 ${ffffff}.", "����", "�������");
		}
		case 631:
		{
			if(!response) return SPD(playerid, 634, DIALOG_STYLE_INPUT, "{34C924}� ��� ���� ��������?", "{ffffff}���� � ��� ���� �������� �� Youtube ������ ��� �������� � ��������� �����, ������� ��� ����:", "����", "�������");
			if(!strlen(inputtextsave)) return SPD(playerid, 631, DIALOG_STYLE_INPUT, "{34C924}������� ��� ������������� ��� ������", "{ffffff}����� �� ������ ������� ��� ������, ������� ��������� ��� �� ������. ����� ����, ��� �� ��������� {fbec5d}24{ffffff} ����, �� ������� {33aa33}50000 ${ffffff}.", "����", "�������");
			if(strlen(inputtextsave) > 20) return SPD(playerid, 632, DIALOG_STYLE_MSGBOX, " ", "{afafaf}���� ��� ������ ��� � ������������ ������.", "X", "");
			format(gInfo[gString], 200, "{ffffff}�������. ��� ������ �� ��������� {fbec5d}24{ffffff} ����, �����, � ������ ������ ��������� ����� {abcdef}%s{ffffff}, ������� {33aa33}50000 ${ffffff}.", inputtextsave);
		    SPD(playerid, 633, DIALOG_STYLE_MSGBOX, " ", gInfo[gString], "X", "");
		    SetString(pInfo[playerid][tRegReferal], inputtextsave);
		}
		case 632: SPD(playerid, 631, DIALOG_STYLE_INPUT, "{34C924}������� ��� ������������� ��� ������", "{ffffff}����� �� ������ ������� ��� ������, ������� ��������� ��� �� ������. ����� ����, ��� �� ��������� {fbec5d}24{ffffff} ����, �� ������� {33aa33}50000 ${ffffff}.", "����", "�������");
		case 633: SPD(playerid, 634, DIALOG_STYLE_INPUT, "{34C924}� ��� ���� ��������?", "{ffffff}���� � ��� ���� �������� �� Youtube ������ ��� �������� � ��������� �����, ������� ��� ����:", "����", "�������");
		case 634:
		{
		    //������� ����� �����.
			if(response)
			{
			    if(!strlen(inputtextsave)) return SPD(playerid, 634, DIALOG_STYLE_INPUT, "{34C924}� ��� ���� ��������?", "{ffffff}���� � ��� ���� �������� �� Youtube ������ ��� �������� � ��������� �����, ������� ��� ����:", "����", "�������");
				SPD(playerid, 635, DIALOG_STYLE_MSGBOX, " ", "{afafaf}���������� ���� ��������� �� ����������.", "X", "");
				return 1;
			}
			for(new i; i < 30; i++) SCM(playerid, -1, "�");
			SPD(playerid, 6, DIALOG_STYLE_MSGBOX, "{34C924}"SERVER_NAME" GTA", "\n{ffffff}����� �� ���������� San Andreas ���������� ��� �����������.\n\n������ ��� ������� ������� � ����� �� ����� �� ����������.\n ", "X", "");
            PlayerSpawn(playerid);
            TogglePlayerControllable(playerid, false);
			SelectRegCity(playerid, 0);
			TextDrawShowForPlayer(playerid, Select_City);
			TextDrawSetStringForPlayer(Select_City, playerid, CityInfo[0][CityName]);
			for(new i; i < 7; i++) TextDrawShowForPlayer(playerid, Select_TD[i]);
			SelectTextDraw(playerid, 0x87CBFFFF);
			pInfo[playerid][tSelectedTD] = 1;
			return 1;
		}
		case 635: SPD(playerid, 634, DIALOG_STYLE_INPUT, "{34C924}� ��� ���� ��������?", "{ffffff}���� � ��� ���� �������� �� Youtube ������ ��� �������� � ��������� �����, ������� ��� ����:", "����", "�������");
		case 3830:
		{
		    if(!response) return EndTalkDynamicActor(playerid);
		    format(gInfo[gString], 100, "��� �� � ��� ����� �������?\n��� �� ������ �� �����������?\n� %s ������� �� ��� ������!", (pInfo[playerid][pSex] == 1) ? "�����" : "������");
		    SPD(playerid, 3831, DIALOG_STYLE_LIST, "{34C924}��� �� ������ ������� ����� ��������?", gInfo[gString], "��������", "��� ����");
		}
		case 3831:
		{
		    if(!response) return EndTalkDynamicActor(playerid);
			if(pInfo[playerid][tSelectedDynamicActor] == 0)
			{
			    switch(listitem)
			    {
			        case 0:
					{
						TalkDynamicActor(playerid);
					    format(gInfo[gString], 600, "\n\n{abcdef}-  %s:{ffffff} ��� �� � ��� ����� �������?\n\n{F5DEB3}-  Francesco Schettino:{ffffff} � ������� ���������� ��������� ����� Santa Huila, � ��� �����, ������� ������� ��� � ���������� �����.\n\n", PN(playerid));
						SPD(playerid, 3832, DIALOG_STYLE_MSGBOX, "{ffffff}NPC {9ACD32}Francesco Schettino", gInfo[gString], "X", "");
					}
					case 1:
					{
						TalkDynamicActor(playerid);
					    format(gInfo[gString], 600, "\n\n{abcdef}-  %s:{ffffff} ��� �� ������ �� �����������?\n\n{F5DEB3}-  Francesco Schettino:{ffffff} ��� ����� ����� ��������� ��������� ������ � ������� �� �����.\n\n", PN(playerid));
						SPD(playerid, 3832, DIALOG_STYLE_MSGBOX, "{ffffff}NPC {9ACD32}Francesco Schettino", gInfo[gString], "X", "");
					}
					case 2:
					{
						EnableGPS(playerid, 1669.6284, -2246.1707, 13.5595);
						TalkDynamicActor(playerid);
						format(gInfo[gString], 600, "\n\n{abcdef}-  %s:{ffffff} � %s ������� �� ��� ������!\n\n{F5DEB3}-  Francesco Schettino:{ffffff} �������, ����������� �� �������� ������. ������ � �����-����������, ��� �������� ������ ������.\n\n\n{fbec5d}���������:{ffffff} ���������, �� ������� � ���� ����� ���������� �������, �������� �� ����� ������.\n{fbec5d}���������:{ffffff} ����� ����, ���� ����� ����� ����� ���� gps ��������� {abcdef}/gps{ffffff}.\n", PN(playerid), (pInfo[playerid][pSex] == 1) ? "�����" : "������");
						SPD(playerid, 46, DIALOG_STYLE_MSGBOX, "{ffffff}NPC {9ACD32}Francesco Schettino", gInfo[gString], "X", "");
					}
				}
			}
			else if(pInfo[playerid][tSelectedDynamicActor] == 1)
			{
				switch(listitem)
			    {
			        case 0:
					{
						TalkDynamicActor(playerid);
					    format(gInfo[gString], 600, "\n\n{abcdef}-  %s:{ffffff} ��� �� � ��� ����� �������?\n\n{F5DEB3}-  Ralf Sikorsky:{ffffff} � �������� ������������� ������ Whetstone, ����� � ��� ����� ������� �������� �� ����.\n\n", PN(playerid));
						SPD(playerid, 3832, DIALOG_STYLE_MSGBOX, "{ffffff}NPC {9ACD32}Ralf Sikorsky", gInfo[gString], "X", "");
					}
					case 1:
					{
						TalkDynamicActor(playerid);
					    format(gInfo[gString], 600, "\n\n{abcdef}-  %s:{ffffff} ��� �� ������ �� �����������?\n\n{F5DEB3}-  Ralf Sikorsky:{ffffff} ��� ����� ����� ������ ��� ��������� ���� ������ �������� � ��������� �� � ������������.\n\n", PN(playerid));
						SPD(playerid, 3832, DIALOG_STYLE_MSGBOX, "{ffffff}NPC {9ACD32}Ralf Sikorsky", gInfo[gString], "X", "");
					}
					case 2:
					{
						EnableGPS(playerid, -1395.6385, -318.0240, 14.1544);
						TalkDynamicActor(playerid);
						format(gInfo[gString], 600, "\n\n{abcdef}-  %s:{ffffff} � %s ������� �� ��� ������!\n\n{F5DEB3}-  Ralf Sikorsky:{ffffff} �������, ����������� �� ������. ��� �� ������� ���������� � ����� ����������.\n\n\n{fbec5d}���������:{ffffff} ���������, �� ������� �� ������ ����� ���������� �������, �������� �� ����� ������.\n{fbec5d}���������:{ffffff} ����� ����, ������ ����� ����� ����� ���� gps ��������� {abcdef}/gps{ffffff}.\n", PN(playerid), (pInfo[playerid][pSex] == 1) ? "�����" : "������");
						SPD(playerid, 46, DIALOG_STYLE_MSGBOX, "{ffffff}NPC {9ACD32}Ralf Sikorsky", gInfo[gString], "X", "");
					}
				}
			}
			else if(pInfo[playerid][tSelectedDynamicActor] == 2)
			{
				switch(listitem)
			    {
			        case 0:
					{
						TalkDynamicActor(playerid);
					    format(gInfo[gString], 600, "\n\n{abcdef}-  %s:{ffffff} ��� �� � ��� ����� �������?\n\n{F5DEB3}-  Francua Lemark:{ffffff} � �������� ����������� ������������ ��������, ����� � ��� �����, ������� ����������� �� �������.\n\n", PN(playerid));
						SPD(playerid, 3832, DIALOG_STYLE_MSGBOX, "{ffffff}NPC {9ACD32}Francua Lemark", gInfo[gString], "X", "");
					}
					case 1:
					{
						TalkDynamicActor(playerid);
					    format(gInfo[gString], 600, "\n\n{abcdef}-  %s:{ffffff} ��� �� ������ �� �����������?\n\n{F5DEB3}-  Francua Lemark:{ffffff} ��� ����� ����� ��������� ��������� ����� �� ������ ����� � ������.\n\n", PN(playerid));
						SPD(playerid, 3832, DIALOG_STYLE_MSGBOX, "{ffffff}NPC {9ACD32}Francua Lemark", gInfo[gString], "X", "");
					}
					case 2:
					{
						EnableGPS(playerid, 1723.6770, 1529.3956, 10.8203);
						TalkDynamicActor(playerid);
						format(gInfo[gString], 600, "\n\n{abcdef}-  %s:{ffffff} � %s ������� �� ��� ������!\n\n{F5DEB3}-  Francua Lemark:{ffffff} �������, ����������� �� �������������. ��� �� ������� ���������� � ����� ����������.\n\n\n{fbec5d}���������:{ffffff} ���������, �� ������� �� ������������� ����� ���������� �������, �������� �� ����� ������.\n{fbec5d}���������:{ffffff} ����� ����, ������� ����� ����� ����� ���� gps ��������� {abcdef}/gps{ffffff}.\n", PN(playerid), (pInfo[playerid][pSex] == 1) ? "�����" : "������");
						SPD(playerid, 46, DIALOG_STYLE_MSGBOX, "{ffffff}NPC {9ACD32}Francua Lemark", gInfo[gString], "X", "");
					}
				}
			}
		}
		case 3832:
		{
		    format(gInfo[gString], 100, "��� �� � ��� ����� �������?\n��� �� ������ �� �����������?\n� %s ������� �� ��� ������!", (pInfo[playerid][pSex] == 1) ? "�����" : "������");
			SPD(playerid, 3831, DIALOG_STYLE_LIST, "{34C924}��� �� ������ ������� ����� ��������?", gInfo[gString], "��������", "��� ����");
		}
		case 3840:
		{
		    if(!response) return EndTalkDynamicActor(playerid);
		    SPD(playerid, 3841, DIALOG_STYLE_LIST, "{34C924}��� �� ������ ������� ����� ��������?", "��� �� ������ ��� �������?\n��� ��������� ��� �������������?\n��� ��������� ���������?", "��������", "��� ����");
		}
		case 3841:
		{
		    if(!response) return EndTalkDynamicActor(playerid);
		    new actor = pInfo[playerid][tSelectedDynamicActor];
		    void actor_name[40];
		    format(actor_name, sizeof(actor_name), "{ffffff}NPC {9ACD32}%s", ActorNames[actor]);
		   	if(pInfo[playerid][pMoney] < 50)
			{
				if(actor == 3) EnableGPS(playerid, 2589.9509, -2239.7490, 13.5390);
				else if(actor == 4) EnableGPS(playerid, -1837.7490, -1647.7460, 21.7560);
				else if(actor == 5) EnableGPS(playerid, 2481.2900, 1958.3840, 10.6360);
				TalkDynamicActor(playerid);
				format(gInfo[gString], 600, "\n\n{abcdef}-  %s:{ffffff} ��� �� ������ ��� �������?\n\n{F5DEB3}-  %s:{ffffff} �� ������ ����� ��� ����������� ���� �� {33aa33}50 ${ffffff}. �� ������ �������� ��, ������� �� ���. � ���������� �� ������ ������ ����� � ���������� � ������.\n\n{fbec5d}���������:{ffffff} ���������� �������� ������� ���������� �� ����� ������.\n\n", PN(playerid), ActorNames[actor]);
				SPD(playerid, 46, DIALOG_STYLE_MSGBOX, actor_name, gInfo[gString], "X", "");
				return 1;
			}
			switch(listitem)
		    {
		        case 0:
				{
					TalkDynamicActor(playerid);
					format(gInfo[gString], 600, "\n\n{abcdef}-  %s:{ffffff} ��� �� ������ ��� �������?\n\n{F5DEB3}-  %s:{ffffff} � ���� �� ��� �������. � ���� �������� ��� ��� ��������� ��� �������������. ������������� ���� � �������� �����������.\n\n", PN(playerid), ActorNames[actor]);
					SPD(playerid, 3842, DIALOG_STYLE_MSGBOX, actor_name, gInfo[gString], "X", "");
				}
				case 1:
				{
					if(actor == 3) EnableGPS(playerid, 1481.0280, -1772.3140, 18.7960);
					else if(actor == 4) EnableGPS(playerid, -2766.5520, 375.7410, 6.3350);
					else if(actor == 5) EnableGPS(playerid, 1042.4700, 1010.5300, 11.0000);
					TalkDynamicActor(playerid);
					format(gInfo[gString], 600, "\n\n{abcdef}-  %s:{ffffff} ��� ��������� ��� �������������?\n\n{F5DEB3}-  %s:{ffffff} ������ ��������, ������� ����� ����.\n\n\n{fbec5d}���������:{ffffff} ��� ������������� ������� ������� ���������� �� ����� ������.", PN(playerid), ActorNames[actor]);
					SPD(playerid, 46, DIALOG_STYLE_MSGBOX, actor_name, gInfo[gString], "X", "");
				}
				case 2:
				{
		    		//������� ����� ��������� ��������.
					if(actor == 3) EnableGPS(playerid, 1481.0280, -1772.3140, 18.7960);
					else if(actor == 4) EnableGPS(playerid, -2766.5520, 375.7410, 6.3350);
					else if(actor == 5) EnableGPS(playerid, 1042.4700, 1010.5300, 11.0000);
					TalkDynamicActor(playerid);
					format(gInfo[gString], 600, "\n\n{abcdef}-  %s:{ffffff} ��� ��������� ���������?\n\n{F5DEB3}-  %s:{ffffff} ��� ������ ��� ����� �������� �������. ������������� � ��� �������������.\n\n\n{fbec5d}���������:{ffffff} ��� ������������� ������� ������� ���������� �� ����� ������.", PN(playerid), ActorNames[actor]);
					SPD(playerid, 46, DIALOG_STYLE_MSGBOX, actor_name, gInfo[gString], "X", "");
				}
		    }
		}
		case 3842: SPD(playerid, 3841, DIALOG_STYLE_LIST, "{34C924}��� �� ������ ������� ����� ��������?", "��� �� ������ ��� �������?\n��� ��������� ��� �������������?\n��� ��������� ���������?", "��������", "��� ����");
		case 4490:
		{
		    if(!response) return 1;
		    if(IsPlayerInAnyVehicle(playerid)) return SPD(playerid, 45, DIALOG_STYLE_MSGBOX, " ", "{afafaf}�� �� ������ ��������������� ������� ������� � ������ ������.", "X", "");
		    new rent = GetPlayerBikeRentID(playerid);
			if(rent == -1) return SPD(playerid, 45, DIALOG_STYLE_MSGBOX, " ", "{afafaf}���������� ��� ������� ������� �����������.", "X", "");
		    pInfo[playerid][tBikeRent] = AddStaticVehicle(510, BikeRent[rent][ArentPosTP][0], BikeRent[rent][ArentPosTP][1], BikeRent[rent][ArentPosTP][2], BikeRent[rent][ArentPosTP][3], random(10), random(10));
			GetVehicleParamsEx(pInfo[playerid][tBikeRent], engine, lights, alarm, doors, bonnet, boot, objective);
		    SetVehicleParamsEx(pInfo[playerid][tBikeRent], engine, lights, alarm, 1, bonnet, boot, objective);
			PutPlayerInVehicle(playerid, pInfo[playerid][tBikeRent], 0);
			SetVehicleParamsForPlayer(pInfo[playerid][tBikeRent], playerid, 0, 0);
		    pInfo[playerid][tBikeRentTime] = 0;
		    SPD(playerid, 45, DIALOG_STYLE_MSGBOX, " ", "{ffffff}��������� ���������. ����������� {fbec5d}/bike{ffffff} �����, ����� ������� ���.", "X", "");
		}
		case 4491:
		{
		    if(!response) return 1;
		    DestroyVehicle(pInfo[playerid][tBikeRent]);
		    pInfo[playerid][tBikeRent] = -1;
		    pInfo[playerid][tBikeRentTime] = 0;
		    SPD(playerid, 45, DIALOG_STYLE_MSGBOX, " ", "{ffffff}�� ���������� �� ������. ��������� ��� ��������� � ������ �������.", "X", "");
		}
		case 7650:
		{
		    if(!response) return 1;
		    switch(listitem)
		    {
		        case 0, 2..7: return callcmd::desc(playerid);
		        case 1:
		        {
	         		SPD(playerid, 7652, DIALOG_STYLE_INPUT, "{34C924}��������� ��������", "{ffffff}������� ����� ��� �������� IC �������� ��������� ������ ���������, ������� ����� ������������ �� ��� �����, ��� {D8A903}CLEAR{ffffff} ��� ������.", "����", "�����");
		        }
		    }
		}
		case 7651: callcmd::desc(playerid);
		case 7652:
		{
		    if(!response) return callcmd::desc(playerid);
		    if(!strlen(inputtextsave)) return SPD(playerid, 7652, DIALOG_STYLE_INPUT, "{34C924}��������� ��������", "{ffffff}������� ����� ��� �������� IC �������� ��������� ������ ���������, ������� ����� ������������ �� ��� �����, ��� {D8A903}CLEAR{ffffff} ��� ������.", "����", "�����");
		    else if(GetString(inputtextsave, "clear", true))
			{
			    if(!strlen(pInfo[playerid][pDescription])) return SPD(playerid, 7653, DIALOG_STYLE_MSGBOX, " ", "{afafaf}��� ������ ��������� � ��� �� ����������� �������� ��������.", "X", "");
				pInfo[playerid][pDescription][0] = EOS;
				UpdatePlayerDataStr(playerid, "Description", pInfo[playerid][pDescription]);
				SPD(playerid, 7651, DIALOG_STYLE_MSGBOX, " ", "{FF8282}����� � ������� ��������� ������ ��������� ��� ������� ������.", "X", "");
			}
			else
			{
				new s = strlen(inputtextsave), p = FindSymbol(inputtextsave, ' ');
			    if(strlen(inputtextsave) > 120) return SPD(playerid, 7653, DIALOG_STYLE_MSGBOX, " ", "{afafaf}����� � ������� ��������� ��������� �� ����� ���� ������� 120 ��������.", "X", "");
				if((s >= 24 && p < 1) || (s >= 48 && p < 2) || (s >= 72 && p < 3)) return SPD(playerid, 7653, DIALOG_STYLE_MSGBOX, " ", "{afafaf}������� �� ������ ������� ��������� ���� ����� �� ��������� �����. ���������������� ���������.", "X", "");
				if(strlen(pInfo[playerid][pDescription]) && GetString(pInfo[playerid][pDescription], inputtextsave)) return SPD(playerid, 7653, DIALOG_STYLE_MSGBOX, " ", "{afafaf}�������� ���� ����� ��������� � ������������� ���������.", "X", "");
				if(strlen(pInfo[playerid][pDescription])) DestroyDynamic3DTextLabel(pInfo[playerid][tDescriptionLabel]);
				SetString(pInfo[playerid][pDescription], inputtextsave);
				UpdatePlayerDataStr(playerid, "Description", pInfo[playerid][pDescription]);
	    		pInfo[playerid][tDescriptionUpdate] = false;
			    format(gInfo[gString], 200, "{ffffff}����������� ��������:{C2A2DA} %s", pInfo[playerid][pDescription]);
		     	SPD(playerid, 7651, DIALOG_STYLE_MSGBOX, " ", gInfo[gString], "X", "");
			}
		}
		case 7653: SPD(playerid, 7652, DIALOG_STYLE_INPUT, "{34C924}��������� ��������", "{ffffff}������� ����� ��� �������� IC �������� ��������� ������ ���������, ������� ����� ������������ �� ��� �����, ��� {D8A903}CLEAR{ffffff} ��� ������.", "����", "�����");
	}
	return 1;
}
public: PlayerSpawn(playerid)
{
	if(IsPlayerNPC(playerid)) return 1;
    if(IsPlayerInAnyVehicle(playerid))//���� ������ ��� ������ � ����
	{
	    new Float:X, Float:Y, Float:Z;
	    GetPlayerPos(playerid, X, Y, Z);
		SetPlayerPos(playerid, X ,Y, Z);
	    SetTimerEx("PlayerSpawn", 50, false, "i", playerid);
	    return 1;
	}
	if(pInfo[playerid][tLogged])
	{
		SetPlayerInterior(playerid, 0);
		SetPlayerVirtualWorld(playerid, 0);
	}
 	SettingSpawn(playerid);
	SpawnPlayer(playerid);
	return 1;
}
public OnPlayerSpawn(playerid)
{
    if(IsPlayerNPC(playerid)) return 1;
	if(!pInfo[playerid][tLogged]) return 0;
	if(!GetPVarInt(playerid, "Animations")) PreloadAnimLib(playerid);
	new hour, minute;
	gettime(hour, minute, _);
    pInfo[playerid][tSpawned] = true;
    ClearAnim(playerid);
    PlayerStopSound(playerid);
	if(pInfo[playerid][tLogged])
	{
		SetPlayerTime(playerid, hour, minute);
		SetPlayerColor(playerid, -1);
 	}
	return 1;
}
public OnPlayerDeath(playerid, killerid, reason)
{
    if(IsPlayerNPC(playerid)) return 1;
    if(!pInfo[playerid][tLogged]) return 0;
    if(!pInfo[playerid][tSpawned]) return 0;
	pInfo[playerid][tSpawned] = false;
   	return 1;
}
public OnPlayerText(playerid, text[])
{
	if(!pInfo[playerid][tLogged]) return 0;
	if(AntiFlood(playerid)) return 0;
	format(gInfo[gString], 145, "%s %s: %s", PN(playerid), (pInfo[playerid][pSex] == 1) ? "������" : "�������", text);
	ProxDetector(10.0, playerid, gInfo[gString], COLOR_GREEN);
	SetPlayerChatBubble(playerid, text, COLOR_GREEN, 10.0, 10000);
	switch(random(3))
	{
	    case 0: ApplyAnimation(playerid, !"PED", !"IDLE_CHAT", 4.1, 0, 1, 1, 1, 1, 1);
	    case 1: ApplyAnimation(playerid, !"LOWRIDER", !"prtial_gngtlkH", 4.1, 0, 1, 1, 1, 1, 1);
	    case 2: ApplyAnimation(playerid, !"GANGS", !"prtial_gngtlkB", 4.1, 0, 1, 1, 1, 1, 1);
	}
	SetTimerEx("ClearAnim", 100 * strlen(text), false, "d", playerid);
	return 0;
}
public: ClearAnim(playerid) return ApplyAnimation(playerid, !"CARRY", !"crry_prtial", 4.0, 0, 0, 0, 0, 0, 1);
public OnPlayerCommandPerformed(playerid, cmd[], params[], result, flags)
{
    if(!pInfo[playerid][tLogged]) return 0;
    if(result == -1)
	{
		SCM(playerid, -1, !"SERVER: Unknown command.");
		return 0;
	}
    return 1;
}
public OnPlayerCommandReceived(playerid, cmd[], params[], flags)
{
    if(!pInfo[playerid][tLogged]) return 0;
	return 1;
}
public OnGameModeInit()
{
    print("========== [ OnGameModeInit ] ==========");
	new currenttime = GetTickCount();
	if(!MySQLConnect()) return 0;
	LoadActors();
	LoadVehicles();
	LoadOther();
	LoadMap();
	LoadBusStop();
	CreateTextDraws();
	new hour;
	gettime(hour, _, _);
	SetWorldTime(hour);
	ShowPlayerMarkers(0);
   	EnableStuntBonusForAll(0);
 	DisableInteriorEnterExits();
    SetTimer("SecondTimer", 1000, true);
	SendRconCommand("hostname |       "SERVER_NAME" Roleplay  �"SERVER_NUMBER"      |");
	SendRconCommand("mapname "SERVER_NAME" World");
	SendRconCommand("weburl "SERVER_URL"");
	SetGameModeText(""SERVER_NAME" GM v "SERVER_VERSION" Roleplay");
	SendRconCommand("language "SERVER_LANGUAGE"");
	return printf("[ServerLoad] OnGameModeInit ���������� ��: %d ms", GetTickCount() - currenttime);
}
public OnGameModeExit()
{
    print("========== [ OnGameModeExit ] ==========");
	new currenttime = GetTickCount();
	DestroyAllDynamicObjects();
	DestroyAllDynamicPickups();
	DestroyAllDynamicCPs();
	DestroyAllDynamicRaceCPs();
	DestroyAllDynamicMapIcons();
	DestroyAllDynamic3DTextLabels();
	DestroyAllDynamicAreas();
	return printf("[ServerUnLoad] OnGameModeExit ���������� ��: %d ms", GetTickCount() - currenttime);
}
public OnPlayerClickTextDraw(playerid, Text:clickedid)
{
 	if(pInfo[playerid][tBackgroundTimer]) return 0;
	if(_:clickedid == INVALID_TEXT_DRAW)
	{
	    if(pInfo[playerid][tSelectedTD]) return SelectTextDraw(playerid, 0x87CBFFFF);
	}
	if(pInfo[playerid][tSelectedTD] == 1)
	{
		if(clickedid == Select_TD[0])
		{
		    CancelSelectTextDraw(playerid);
			TextDrawHideForPlayer(playerid, Select_City);
			for(new i; i < 7; i++) TextDrawHideForPlayer(playerid, Select_TD[i]);
			ShowRegisterCutscene(playerid);
			pInfo[playerid][tSelectedTD] = 0;
			return 1;
		}
		if(clickedid == Select_TD[1])
		{
		    new next;
		    if(pInfo[playerid][tRegCity] == 2) next = 0;
			else next = pInfo[playerid][tRegCity] + 1;
		    SelectRegCity(playerid, next);
			return 1;
		}
		if(clickedid == Select_TD[2])
		{
		    new prev;
		    if(pInfo[playerid][tRegCity] == 0) prev = 2;
			else prev = pInfo[playerid][tRegCity] - 1;
		    SelectRegCity(playerid, prev);
			return 1;
		}
	}
	else if(pInfo[playerid][tSelectedTD] == 2)
	{
		if(clickedid == Select_TD[0])
		{
			for(new i; i < 7; i++) TextDrawHideForPlayer(playerid, Select_TD[i]);
			ApplyAnimation(playerid, "CLOTHES", "CLO_Buy", 4.1, 0, 1, 1, 1, 1);
			ShowBackgroundForPlayer(playerid, 2);
			return 1;
		}
		if(clickedid == Select_TD[1])
		{
			if(pInfo[playerid][tRegSkin] == 15) pInfo[playerid][tRegSkin] = 0;
			else pInfo[playerid][tRegSkin] += 1;
		    SetPlayerSkin(playerid, RegSkins[pInfo[playerid][tRegSex]][pInfo[playerid][tRegSkin]]);
			ChangeSkinAnim(playerid, 1);
			return 1;
		}
		if(clickedid == Select_TD[2])
		{
			if(pInfo[playerid][tRegSkin] == 0) pInfo[playerid][tRegSkin] = 15;
			else pInfo[playerid][tRegSkin] -= 1;
		    SetPlayerSkin(playerid, RegSkins[pInfo[playerid][tRegSex]][pInfo[playerid][tRegSkin]]);
			ChangeSkinAnim(playerid, 1);
			return 1;
		}
	}
	return 1;
}
public: SecondTimer()
{
	new hour, minute, second;
	gettime(hour, minute, second);
	if(minute == 0 && !gInfo[tPayDay][hour]) PayDay();
	UpdateBusMap();
	return 1;
}
public: PlayerTimer(playerid)
{
	if(IsPlayerNPC(playerid)) return 1;
	new hour, minute, second;
	gettime(hour, minute, second);
	if(second == 0)
	{
	    PlayerTextDrawSetString(playerid, Time_TD[playerid][1], GetTime(1));
	    PlayerTextDrawSetString(playerid, Time_TD[playerid][0], GetTime(2));
	}
	if(!pInfo[playerid][tLogged] && pInfo[playerid][tChecked] && pInfo[playerid][tLoginTime] < gettime())
	{
	    SCM(playerid, 0xF5DEB3FF, "�� �� ������ ����� � ������� �� ���������� ��� ����� �����, � ���� ������� �� ����������� ������������.");
	    HPD(playerid);
	    SetPlayerRandomCamera(playerid);
	    Kick(playerid);
	}
	if(pInfo[playerid][tBikeRent] != -1)
	{
		if(GetPlayerVehicleID(playerid) != pInfo[playerid][tBikeRent]) pInfo[playerid][tBikeRentTime]++;
		if(pInfo[playerid][tBikeRentTime] >= 60)
		{
		    DestroyVehicle(pInfo[playerid][tBikeRent]);
		    pInfo[playerid][tBikeRent] = -1;
		    pInfo[playerid][tBikeRentTime] = 0;
		}
	}
	if(GetTickCount() - pInfo[playerid][tAFK] > 1200) SetPlayerChatBubble(playerid, "<{34C924} AFK {ffffff}>", -1, 8.0, 3000);
	if(pInfo[playerid][tGreenZoneTime])
	{
		pInfo[playerid][tGreenZoneTime]--;
		if(!pInfo[playerid][tGreenZoneTime])
		{
			HPD(playerid);
			SCM(GetPVarInt(playerid, "GreenZoneDamagedID"), COLOR_RED, "���� �������� ������ �� �������� �� ������ �����.");
			DeletePVar(playerid, "GreenZoneDamagedID");
		}
	}
	if(strlen(pInfo[playerid][pDescription]) && !pInfo[playerid][tDescriptionUpdate])
	{
		ShowDescription(pInfo[playerid][pDescription], gInfo[gString]);
	    pInfo[playerid][tDescriptionLabel] = CreateDynamic3DTextLabel(gInfo[gString], 0xAFAFAFEE, 0.0, 0.0, -0.6, 10.0, playerid);
	    pInfo[playerid][tDescriptionUpdate] = true;
	}
	else if(!strlen(pInfo[playerid][pDescription]) && pInfo[playerid][tDescriptionUpdate])
	{
	    DestroyDynamic3DTextLabel(pInfo[playerid][tDescriptionLabel]);
	    pInfo[playerid][tDescriptionUpdate] = false;
	}
	if(pInfo[playerid][tCameraObject] != -1 && !IsPlayerObjectMoving(playerid, pInfo[playerid][tCameraObject]))
	{
	    if(pInfo[playerid][tRegCity] == 0 && pInfo[playerid][tCameraStage] == 1)
	    {
			ObjectCameraPos(playerid, 1500.7531, -2519.8330, 14.5368, 1532.6957, -2461.8044, 14.7832, 1685.455, -2436.981, 13.555, 270.0, 45);
			MovePlayerObject(playerid, pInfo[playerid][tPlaneObject], 1740.288, -2494.586, 14.653, 80, 0.0, 0.0, 270.0);
			pInfo[playerid][tCameraStage] = 2;
	    }
	    else if(pInfo[playerid][tRegCity] == 1 && pInfo[playerid][tCameraStage] == 1)
	    {
			ObjectCameraPos(playerid, -1400.237, 140.717, 15.469, -1420.6990, -174.3088, 14.1484, -1419.899, -168.452, 14.478, 0.0, 45);
			MovePlayerObject(playerid, pInfo[playerid][tPlaneObject], -1632.914, -140.205, 15.275, 80, 0.0, 0.0, 135.0);
			pInfo[playerid][tCameraStage] = 2;
	    }
	    else if(pInfo[playerid][tRegCity] == 2 && pInfo[playerid][tCameraStage] == 1)
	    {
			ObjectCameraPos(playerid, 1361.442, 1315.747, 10.820, 1512.3481, 1270.4568, 12.2447, 1587.191, 1447.770, 10.834, 0.0, 70);
			MovePlayerObject(playerid, pInfo[playerid][tPlaneObject], 1477.338, 1600.000, 11.977, 60, 0.0, 0.0, 0.0);
			pInfo[playerid][tCameraStage] = 2;
	    }
	    else if(pInfo[playerid][tCameraStage] == 2)
	    {
		    ShowBackgroundForPlayer(playerid, 1);
   		}
	}
	if(pInfo[playerid][tFreezeTime])
	{
	    pInfo[playerid][tFreezeTime]--;
		if(!pInfo[playerid][tFreezeTime]) TogglePlayerControllable(playerid, true);
	}
	if(pInfo[playerid][tPTJob] != -1)
	{
	    new ptjobid = pInfo[playerid][tPTJob];
		if(!IsPlayerInRangeOfPoint(playerid, 100, PTJob[ptjobid][jPos][0], PTJob[ptjobid][jPos][1], PTJob[ptjobid][jPos][2]) &&
		   !IsPlayerInRangeOfPoint(playerid, 30, -2200.9893, 405.8916, 2166.0300) &&
		   !IsPlayerInRangeOfPoint(playerid, 30, -2203.3623, 413.9457, 2166.0300))
		{
		    PTJobEnd(playerid);
		    SCM(playerid, 0x33AA33FF, "�� �������� ����� ���������� ����� � ���� ���������� �� ������� � ���.");
		}
	}
	return 1;
}
public OnPlayerEnterCheckpoint(playerid)
{
    if(pInfo[playerid][tGPS] != -1)
	{
	    pInfo[playerid][tGPS] = -1;
		DisablePlayerCheckpoint(playerid);
	}
	return 1;
}
public OnPlayerEnterDynamicCP(playerid, checkpointid)
{
	//������ �������� LS
	if(checkpointid == PTJobCP[1])
	{
	    if(pInfo[playerid][tPTJob] != 0) return 0;
		if(GetPVarInt(playerid, "PTJobObject") != 1) return 0;
		DeletePVar(playerid, "PTJobObject");
		RemovePlayerAttachedObject(playerid, 0);
		SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
		ClearAnim(playerid);
		TogglePlayerDynamicCP(playerid, PTJobCP[0], true);
		TogglePlayerDynamicCP(playerid, PTJobCP[1], false);
		new ptjobcount = GetPVarInt(playerid, "PTJobCount");
		if(!ptjobcount)
		{
			SCM(playerid, -1, "�� ��������� {A52A2A}1{ffffff} ����.");
			SCM(playerid, 0x9ACD32FF, "�����������: �� ������ ���������� ��������� ������. ��� ������ �� �������� �������� ������ - ������������� � �����.");
		}
		else SCMf(playerid, -1, "�� ��������� {A52A2A}%d{ffffff} ����%s.", (ptjobcount + 1), (ptjobcount >= 1 && ptjobcount <= 3) ? "�" : "��");
		SetPVarInt(playerid, "PTJobCount", ptjobcount + 1);
		pInfo[playerid][pPTJobCount]++;
	}
	//������ ������� SF
	if(checkpointid == PTJobCP[3])
	{
	    if(pInfo[playerid][tPTJob] != 1) return 0;
		if(GetPVarInt(playerid, "PTJobObject") != 1) return 0;
		DeletePVar(playerid, "PTJobObject");
		RemovePlayerAttachedObject(playerid, 0);
		SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
		ClearAnim(playerid);
		TogglePlayerDynamicCP(playerid, PTJobCP[2], true);
		TogglePlayerDynamicCP(playerid, PTJobCP[3], false);
		new ptjobcount = GetPVarInt(playerid, "PTJobCount");
		if(!ptjobcount)
		{
			SCM(playerid, -1, "�� ��������� {A52A2A}1{ffffff} ��������.");
			SCM(playerid, 0x9ACD32FF, "�����������: �� ������ ���������� ��������� ���. ��� ������ �� �������� �������� ������ - ������������� � �����.");
		}
		else SCMf(playerid, -1, "�� ��������� {A52A2A}%d{ffffff} ������%s.", (ptjobcount + 1), (ptjobcount >= 1 && ptjobcount <= 3) ? "��" : "��");
  		SetPVarInt(playerid, "PTJobCount", ptjobcount + 1);
		pInfo[playerid][pPTJobCount]++;
	}
	//������ ��������� LV
	if(checkpointid == PTJobCP[5])
	{
	    if(pInfo[playerid][tPTJob] != 2) return 0;
		if(GetPVarInt(playerid, "PTJobObject") != 1) return 0;
		DeletePVar(playerid, "PTJobObject");
		RemovePlayerAttachedObject(playerid, 0);
		SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
		ClearAnim(playerid);
		TogglePlayerDynamicCP(playerid, PTJobCP[4], true);
		TogglePlayerDynamicCP(playerid, PTJobCP[5], false);
		new ptjobcount = GetPVarInt(playerid, "PTJobCount");
		if(!ptjobcount)
		{
			SCM(playerid, -1, "�� ��������� {A52A2A}1{ffffff} �����.");
			SCM(playerid, 0x9ACD32FF, "�����������: �� ������ ���������� ��������� �����. ��� ������ �� �������� �������� ������ - ������������� � �����.");
		}
		else SCMf(playerid, -1, "�� ��������� {A52A2A}%d{ffffff} ���%s.", (ptjobcount + 1), (ptjobcount >= 1 && ptjobcount <= 3) ? "��" : "��");
  		SetPVarInt(playerid, "PTJobCount", ptjobcount + 1);
		pInfo[playerid][pPTJobCount]++;
	}
	return 1;
}
public OnPlayerEnterDynamicArea(playerid, areaid)
{
	for(new i; i < sizeof(GreenZone); i++)
	{
	    if(areaid != GreenZone[i][gZone]) continue;
	    if(GetPlayerVirtualWorld(playerid) != GreenZone[i][gWorld]) continue;
	    if(GetPlayerInterior(playerid) != GreenZone[i][gInterior]) continue;
	    TextDrawShowForPlayer(playerid, GreenZone_TD);
	    pInfo[playerid][tGreenZone] = true;
	    break;
	}
    return 1;
}
public OnPlayerLeaveDynamicArea(playerid, areaid)
{
	for(new i; i < sizeof(GreenZone); i++)
	{
	    if(areaid != GreenZone[i][gZone]) continue;
	    TextDrawHideForPlayer(playerid, GreenZone_TD);
	    pInfo[playerid][tGreenZone] = false;
		break;
	}
    return 1;
}
public OnPlayerGiveDamage(playerid, damagedid, Float: amount, weaponid, bodypart)
{
	if(pInfo[playerid][tGreenZone])
	{
	    new Float:health;
		GetPlayerHealth(damagedid, health);
		SetPlayerHealth(damagedid, health+amount);
		pInfo[playerid][tGreenZoneTime] = 3;
	    SetPVarInt(playerid, "GreenZoneDamagedID", damagedid);
		ApplyAnimation(playerid, "PED", "GAS_CWR", 4.1, 0, 0, 0, 0, 0);
 		SPD(playerid, 271, DIALOG_STYLE_MSGBOX, "{34C924}�� � ������� ����", "\n{ffffff}�� ���� ���������� �� �� ������� ������� ���� ������ �������. ��� ��������� ������������� ��������� ����� {abcdef}3{ffffff} �������.\n", "X", "");
		SCM(damagedid, COLOR_RED, "�� ���������� ��� �������������� ������� �� �������� �� ������.");
		SCM(damagedid, COLOR_RED, "������ �� �� ������ ��� �������� ����, ��� � �������� ��� ������.");
		return 0;
	}
	return 1;
}
public OnPlayerStateChange(playerid, newstate, oldstate)
{
    if(newstate == PLAYER_STATE_DRIVER)
    {
        if(pInfo[playerid][tBrightnessColor] == -1)
        {
	        new carid = GetPlayerVehicleID(playerid);
			new model = GetVehicleModel(carid);

			if(!GetPVarInt(playerid, "ShowedBrightnessTextDraw"))
			{
				#include ../library/TextDraws/Player/CarName

				for(new i; i < 2; i++) TextDrawShowForPlayer(playerid, CarName_Global[i]);

				ShowBrightnessTextDraw(playerid, 1, 1);
			}
		}
		if(GetPlayerVehicleID(playerid) == pInfo[playerid][tBikeRent]) pInfo[playerid][tBikeRentTime] = 0;
	}
	return 1;
}
public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	//new Str[34]; format(Str,sizeof(Str),"%d - newkeys, %d - oldkeys",newkeys,oldkeys); SendClientMessage(playerid,0xFF0000ff,Str);
	if(newkeys == KEY_WALK)//����� ALT
	{
	    if(GetPlayerDynamicActorID(playerid) != -1) callcmd::talk(playerid);
	}
	else if(newkeys == KEY_FIRE)//����/ALT � ����������
	{
	    if(IsPlayerInAnyVehicle(playerid)) if(GetPlayerDynamicActorID(playerid) != -1) callcmd::talk(playerid);
	}
	else if(newkeys == KEY_HANDBRAKE)//������ ������ ����
	{
		//������ �������� LS
	    if(pInfo[playerid][tPTJob] == 0 && IsPlayerInRangeOfPoint(playerid, 5, 2638.9382, -2277.3389, 8.5369) && GetPVarInt(playerid, "PTJobObject") != 1 && !IsPlayerInAnyVehicle(playerid))
	    {
            if(pInfo[playerid][pPTJobCount] >= 50) return SCM(playerid, COLOR_GREY, "�� ��������� ����������� ���������� ����� ������ ���������, ������������� � ����� �� ���������.");
	        SetPVarInt(playerid, "PTJobObject", 1);
	        SetPlayerAttachedObject(playerid, 0, 3052, 5, 0.0100, 0.1100, 0.2000, -80.0000, 0.0000, 105.0000, 1.0000, 1.0000, 1.0000, 0, 0);
        	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_CARRY);
			TogglePlayerDynamicCP(playerid, PTJobCP[0], false);
			TogglePlayerDynamicCP(playerid, PTJobCP[1], true);
	    }
		//������ ������� SF
	    if(pInfo[playerid][tPTJob] == 1 && IsPlayerInRangeOfPoint(playerid, 5, -1795.1847, -1648.5120, 31.2409) && GetPVarInt(playerid, "PTJobObject") != 1 && !IsPlayerInAnyVehicle(playerid))
	    {
            if(pInfo[playerid][pPTJobCount] >= 50) return SCM(playerid, COLOR_GREY, "�� ��������� ����������� ���������� ����� ������ ���������, ������������� � ����� �� ���������.");
	        SetPVarInt(playerid, "PTJobObject", 1);
			SetPlayerAttachedObject(playerid, 0, 1025, 5, 0.0100, 0.4200, 0.2000, -80.0000, 0.0000, 15.0000, 1.0000, 1.0000, 1.0000, 0, 0);
        	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_CARRY);
			TogglePlayerDynamicCP(playerid, PTJobCP[2], false);
			TogglePlayerDynamicCP(playerid, PTJobCP[3], true);
	    }
		//������ ��������� LV
	    if(pInfo[playerid][tPTJob] == 2 && IsPlayerInRangeOfPoint(playerid, 5, 2430.4773, 1933.2249, 6.0156) && GetPVarInt(playerid, "PTJobObject") != 1 && !IsPlayerInAnyVehicle(playerid))
	    {
            if(pInfo[playerid][pPTJobCount] >= 50) return SCM(playerid, COLOR_GREY, "�� ��������� ����������� ���������� ����� ������ ���������, ������������� � ����� �� ���������.");
	        SetPVarInt(playerid, "PTJobObject", 1);
			SetPlayerAttachedObject(playerid, 0, 2960, 5, 0.0100, 0.3500, 0.2000, -80.0000, 0.0000, 105.0000, 1.0000, 1.0000, 1.0000, 0, 0);
        	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_CARRY);
			TogglePlayerDynamicCP(playerid, PTJobCP[4], false);
			TogglePlayerDynamicCP(playerid, PTJobCP[5], true);
	    }
	}
	else if(newkeys == KEY_SECONDARY_ATTACK)//Enter/F
	{
		//������ �������� LS
		if(pInfo[playerid][tPTJob] == 0 && GetPVarInt(playerid, "PTJobObject") == 1)
		{
			DeletePVar(playerid, "PTJobObject");
			RemovePlayerAttachedObject(playerid, 0);
			SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
			ClearAnim(playerid);
			TogglePlayerDynamicCP(playerid, PTJobCP[0], true);
			TogglePlayerDynamicCP(playerid, PTJobCP[1], false);
		    SCM(playerid, 0xFFBB44FF, "�� �������� ����.");
	    }
		//������ ������� SF
		if(pInfo[playerid][tPTJob] == 1 && GetPVarInt(playerid, "PTJobObject") == 1)
		{
			DeletePVar(playerid, "PTJobObject");
			RemovePlayerAttachedObject(playerid, 0);
			SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
			ClearAnim(playerid);
			TogglePlayerDynamicCP(playerid, PTJobCP[2], true);
			TogglePlayerDynamicCP(playerid, PTJobCP[3], false);
		    SCM(playerid, 0xFFBB44FF, "�� �������� ��������.");
	    }
		//������ ��������� LV
		if(pInfo[playerid][tPTJob] == 2 && GetPVarInt(playerid, "PTJobObject") == 1)
		{
			DeletePVar(playerid, "PTJobObject");
			RemovePlayerAttachedObject(playerid, 0);
			SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
			ClearAnim(playerid);
			TogglePlayerDynamicCP(playerid, PTJobCP[4], true);
			TogglePlayerDynamicCP(playerid, PTJobCP[5], false);
		    SCM(playerid, 0xFFBB44FF, "�� �������� �����.");
	    }
	}
	return 1;
}
public OnPlayerPickUpDynamicPickup(playerid, pickupid)
{
	if(GetPVarInt(playerid, "PickupFlood") > gettime()) return 1;
	SetPVarInt(playerid, "PickupFlood", gettime() + 1);
	if(GetPVarInt(playerid, "DialogID") != -1) return 1;
	for(new i; i < sizeof(Pickup); i++)
	{
	    if(pickupid != Pickup[i][pID]) continue;
	    SetPlayerPos(playerid, Pickup[i][pPosEnter][0], Pickup[i][pPosEnter][1], Pickup[i][pPosEnter][2]);
	    SetPlayerFacingAngle(playerid, Pickup[i][pPosEnter][3]);
	    SetPlayerVirtualWorld(playerid, Pickup[i][pVirtualWorldEnter]);
	    SetPlayerInterior(playerid, Pickup[i][pInteriorEnter]);
	    SetCameraBehindPlayer(playerid);
	    if(Pickup[i][pVirtualWorldEnter] != 0 && Pickup[i][pInteriorEnter] != 0) SetPlayerTime(playerid, 12, 0);
		else
		{
			new hour;
			gettime(hour, _, _);
			SetPlayerTime(playerid, hour, 0);
		}
	    Freeze(playerid, 1);
	    switch(i)
	    {
	        case 3, 7, 11:
			{
				if(GetPVarInt(playerid, "PTJobEnded"))
				{
					SetTimerEx("OnPlayerExitPTJob", 200 + GetPlayerPing(playerid), false, "dd", playerid, i);//����� ��������� �����
					DeletePVar(playerid, "PTJobEnded");
				}
				
			}
	    }
	    break;
	}
	for(new i; i < sizeof(PTJob); i++)
	{
	    if(pickupid != PTJob[i][jLockerRoomPickupID] && pickupid != PTJob[i][jCashPickupID]) continue;
		if(pickupid == PTJob[i][jLockerRoomPickupID]) PTJobDialogStart(playerid, i);
  		else if(pickupid == PTJob[i][jCashPickupID]) PTJobDialogEnd(playerid, i);
	    break;
	}
	return 1;
}
public: OnPlayerExitPTJob(playerid, ptjobid)
{
    new actor;
    if(ptjobid == 3) actor = 3;
    else if(ptjobid == 7) actor = 4;
    else if(ptjobid == 11) actor = 5;
	SetCameraToDynamicActor(playerid, gInfo[gDynamicActor][actor]);
	ApplyDynamicActorAnimation(gInfo[gDynamicActor][actor], "PED", "IDLE_CHAT", 4.0, 0, 0, 0, 0, 0);
    void actor_name[40];
    format(actor_name, sizeof(actor_name), "{ffffff}NPC {9ACD32}%s", ActorNames[actor]);
	format(gInfo[gString], 144, "\n\n{F5DEB3}-  %s:{ffffff} ��, {abcdef}%s{ffffff}! � ���� ������ ����. �������� �� ����.\n\n", ActorNames[actor], PN(playerid));
	SPD(playerid, 46, DIALOG_STYLE_MSGBOX, actor_name, gInfo[gString], "X", "");
}
public OnPlayerUpdate(playerid)
{
	pInfo[playerid][tAFK] = GetTickCount();
	return 1;
}
public: ShowBrightnessTextDraw(playerid, type, start)
{
	if(start)
	{
	    if(GetPVarInt(playerid, "ShowedBrightnessTextDraw")) return 0;
		SetPVarInt(playerid, "ShowedBrightnessTextDraw", 1);
	    pInfo[playerid][tBrightnessColor] = 0;
	}
	new color = pInfo[playerid][tBrightnessColor];
	if(type == 1)//�������� ����������, ��� ������� � ����
	{
	    PlayerTextDrawColor(playerid, CarName_Player[playerid], BrightnessColors[color][0]);
	    PlayerTextDrawBackgroundColor(playerid, CarName_Player[playerid], BrightnessColors[color][1]);
		PlayerTextDrawShow(playerid, CarName_Player[playerid]);
	}
	else if(type == 2)//������
	{
	    PlayerTextDrawColor(playerid, GiveMoney_Player[playerid], BrightnessColors[color][0]);
	    PlayerTextDrawBackgroundColor(playerid, GiveMoney_Player[playerid], BrightnessColors[color][1]);
		PlayerTextDrawShow(playerid, GiveMoney_Player[playerid]);
	}
	if(color < sizeof(BrightnessColors) - 1)
	{
	    pInfo[playerid][tBrightnessColor]++;
	    SetTimerEx("ShowBrightnessTextDraw", 50, false, "iii", playerid, type, 0);
	}
	else
	{
	    pInfo[playerid][tBrightnessColor] = -1;
		if(type == 1)//�������� ����������, ��� ������� � ����
		{
			for(new i; i < 2; i++) TextDrawHideForPlayer(playerid, CarName_Global[i]);
			PlayerTextDrawDestroy(playerid, CarName_Player[playerid]);
		}
		else if(type == 2)//������
		{
			PlayerTextDrawDestroy(playerid, GiveMoney_Player[playerid]);
		}
		DeletePVar(playerid, "ShowedBrightnessTextDraw");
	}
	return 1;
}
public: PlaneMove(playerid, Float:dest_x, Float:dest_y, Float:dest_z, speed, Float:rot_x, Float:rot_y, Float:rot_z)
{
	MovePlayerObject(playerid, pInfo[playerid][tPlaneObject], dest_x, dest_y, dest_z, speed, rot_x, rot_y, rot_z);
	return 1;
}
public: Background_Timer(playerid, type)
{
    PlayerTextDrawBoxColor(playerid, Background_TD[playerid], pInfo[playerid][tBackgroundBox]);
    PlayerTextDrawShow(playerid, Background_TD[playerid]);

    if(type == 1)
    {
        pInfo[playerid][tBackgroundBox] += 20;
        if(pInfo[playerid][tBackgroundBox] >= 255)
		{
        	pInfo[playerid][tBackgroundBox] = 255;
			KillTimer(pInfo[playerid][tBackgroundTimer]);
            pInfo[playerid][tBackgroundTimer] = 0;
    		HideBackgroundForPlayer(playerid);
    		new background_show_td = GetPVarInt(playerid, "BackgroundShowTD");
    		if(background_show_td == 1)
    		{
	    		PlayerTextDrawSetString(playerid, Time_TD[playerid][1], GetTime(1));
			    PlayerTextDrawSetString(playerid, Time_TD[playerid][0], GetTime(2));
				for(new i; i < 2; i++) PlayerTextDrawShow(playerid, Time_TD[playerid][i]);
				for(new i; i < 2; i++) TextDrawHideForPlayer(playerid, Black_Background[i]);
				DestroyPlayerObject(playerid, pInfo[playerid][tCameraObject]);
				DestroyPlayerObject(playerid, pInfo[playerid][tPlaneObject]);
		        pInfo[playerid][tCameraObject] = -1;
		        pInfo[playerid][tPlaneObject] = -1;
				TogglePlayerSpectating(playerid, false);
				//����� ����� ��� �����������
			    pInfo[playerid][tRegSkin] = 0;
				SetPlayerSkin(playerid, RegSkins[pInfo[playerid][tRegSex]][0]);
			    SetPlayerPos(playerid, 1983.1676, 2113.2493, 2001.5864);
			    SetPlayerFacingAngle(playerid, 20.5628);
				SetPlayerCameraPos(playerid, 1980.6267, 2110.1599, 2002.3865);
				SetPlayerCameraLookAt(playerid, 1983.1676, 2113.2493, 2001.8865);
				SetPlayerInterior(playerid, 7);
		    	SetPlayerTime(playerid, 12, 0);
				Freeze(playerid, 5);
				ChangeSkinAnim(playerid, 0);
				SetTimerEx("ChangeSkinAnim", 1500, false, "ii", playerid, 0);
				for(new i; i < 7; i++) TextDrawShowForPlayer(playerid, Select_TD[i]);
				SelectTextDraw(playerid, 0x87CBFFFF);
				pInfo[playerid][tSelectedTD] = 2;
    		}
            else if(background_show_td == 2)
            {
				OnPlayerRegister(playerid);
			    SPD(playerid, 68, DIALOG_STYLE_MSGBOX, "{34C924}�� ���� ������ ��� �� ����� �������!", "{ffffff}������ ���� ��� ������� ������� ������� ��������� � NPC ����������. �� ����� �� ������������.", "X", "");
				pInfo[playerid][tSelectedTD] = 0;
				CancelSelectTextDraw(playerid);
            }
            DeletePVar(playerid, "BackgroundShowTD");
		}
    }
    else
    {
        pInfo[playerid][tBackgroundBox] -= 20;
        if(pInfo[playerid][tBackgroundBox] <= 0)
        {
        	pInfo[playerid][tBackgroundBox] = 0;
            PlayerTextDrawDestroy(playerid, Background_TD[playerid]);
            KillTimer(pInfo[playerid][tBackgroundTimer]);
            pInfo[playerid][tBackgroundTimer] = 0;
        }
    }
    return 1;
}
//=============================[ ����� ]=============================//
stock LoadActors()
{
	new currenttime = GetTickCount();
	
    gInfo[gDynamicActor][0] = CreateDynamicActor(182, 1650.5518, -2245.0125, 13.5059, 54.8339, true, 100.0, 0, 0);
    CreateDynamic3DTextLabel("NPC {D8A903}Francesco Schettino\n\n{ffffff}������� {33aa33}ALT{ffffff} ��� ���������.", 0xFFFFFFFF, 1650.5518, -2245.0125, 14.6059, 7.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, 0, 0);
    gInfo[gDynamicActorTalk][0] = true;

	gInfo[gDynamicActor][1] = CreateDynamicActor(259, -1412.5531, -301.8500, 14.1411, 32.9003, true, 100.0, 0, 0);
	CreateDynamic3DTextLabel("NPC {D8A903}Ralf Sikorsky\n\n{ffffff}������� {33aa33}ALT{ffffff} ��� ���������.", 0xFFFFFFFF, -1412.5531, -301.8500, 15.2411, 7.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, 0, 0);
	gInfo[gDynamicActorTalk][1] = true;
	
	gInfo[gDynamicActor][2] = CreateDynamicActor(153, 1684.8441, 1456.8380, 10.7704, 126.9012, true, 100.0, 0, 0);
	CreateDynamic3DTextLabel("NPC {D8A903}Francua Lemark\n\n{ffffff}������� {33aa33}ALT{ffffff} ��� ���������.", 0xFFFFFFFF, 1684.8441, 1456.8380, 11.8704, 7.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, 0, 0);
	gInfo[gDynamicActorTalk][2] = true;
	
	gInfo[gDynamicActor][3] = CreateDynamicActor(119, 2619.2312, -2248.2744, 13.5469, 63.2107, true, 100.0, 0, 0);
	CreateDynamic3DTextLabel("NPC {D8A903}Richard Beckwith\n\n{ffffff}������� {33aa33}ALT{ffffff} ��� ���������.", 0xFFFFFFFF, 2619.2312, -2248.2744, 14.6469, 7.0000, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, 0, 0);
	gInfo[gDynamicActorTalk][3] = true;

	gInfo[gDynamicActor][4] = CreateDynamicActor(129, -1815.7185, -1662.8625, 21.9052, 33.8918, true, 100.0, 0, 0);
	CreateDynamic3DTextLabel("NPC {D8A903}Sallie Beckwith\n\n{ffffff}������� {33aa33}ALT{ffffff} ��� ���������.", 0xFFFFFFFF, -1815.7185, -1662.8625, 23.0052, 7.0000, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, 0, 0);
	gInfo[gDynamicActorTalk][4] = true;

	gInfo[gDynamicActor][5] = CreateDynamicActor(305, 2451.3665, 1959.8339, 10.6669, 165.3352, true, 100.0, 0, 0);
	CreateDynamic3DTextLabel("NPC {D8A903}Karl Behr\n\n{ffffff}������� {33aa33}ALT{ffffff} ��� ���������.", 0xFFFFFFFF, 2451.3665, 1959.8339, 11.7669, 7.0000, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, 0, 0);
	gInfo[gDynamicActorTalk][5] = true;

	gInfo[gDynamicActor][6] = CreateDynamicActor(153, -1862.6567, -1716.1908, 21.7500, 159.0047, true, 100.0, 0, 0);
	CreateDynamic3DTextLabel("NPC {D8A903}������������� ��������{ffffff}", 0xFFFFFFFF, -1862.6567, -1716.1908, 22.8500, 7.0000, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, 0, 0);

	return printf("[ServerLoad] LoadActors ���������� ��: %d ms", GetTickCount() - currenttime);
}
stock LoadVehicles()
{
	new currenttime = GetTickCount();
	//������ �� ������ LS
	AddStaticVehicle(510,1646.9980,-2261.9978,12.9972,23.9966,0,0);
	AddStaticVehicle(510,1644.9977,-2261.9980,12.9974,23.9970,2,2);
	AddStaticVehicle(510,1642.9958,-2261.9919,13.0672,23.9904,1,1);
	AddStaticVehicle(510,1640.9414,-2261.8704,13.0542,24.0031,6,6);
	AddStaticVehicle(510,1638.9967,-2261.9919,13.0685,24.0037,6,6);
	AddStaticVehicle(510,1636.8531,-2261.9841,13.0824,26.3218,0,0);
	AddStaticVehicle(510,1634.6066,-2261.9829,13.0845,24.8369,1,1);
	AddStaticVehicle(510,1632.5875,-2261.8015,13.0647,37.5726,3,3);
	AddStaticVehicle(510,1630.7531,-2261.9329,13.0879,37.0385,6,6);
	//������ - ������ �������� LS
	AddStaticVehicle(510,2597.3833,-2214.8682,13.0894,197.4663,6,6);
	AddStaticVehicle(510,2599.2654,-2214.7773,13.1272,199.1332,1,1);
	AddStaticVehicle(510,2601.0991,-2214.8899,13.1253,197.4732,0,0);
	//������ �� ������ SF
	AddStaticVehicle(510,-1448.6892,-272.2679,13.7568,166.7677,99,99);
	AddStaticVehicle(510,-1446.5740,-273.3124,13.7435,181.5998,86,86);
	AddStaticVehicle(510,-1444.5811,-274.3478,13.7295,176.1971,1,1);
	AddStaticVehicle(510,-1442.6281,-275.0656,13.7421,177.1072,183,183);
	AddStaticVehicle(510,-1440.6580,-275.9871,13.7411,180.5303,0,0);
	AddStaticVehicle(510,-1438.5780,-277.1244,13.7492,178.9331,1,1);
	AddStaticVehicle(510,-1436.5861,-278.3296,13.7241,176.5024,53,53);
	AddStaticVehicle(510,-1434.6860,-279.6298,13.7435,181.2422,3,3);
	//������ - ������ ������� SF
	AddStaticVehicle(510,-1902.0250,-1699.0436,21.3284,185.8291,3,2);
	AddStaticVehicle(510,-1899.7114,-1698.9714,21.3440,186.2891,5,5);
	AddStaticVehicle(510,-1897.5931,-1698.9487,21.3421,183.7991,6,6);
	//������ �� ������ LV
	AddStaticVehicle(510,1695.9755,1420.2261,10.3570,290.3063,0,0);
	AddStaticVehicle(510,1696.5345,1417.5355,10.3557,298.7068,5,5);
	AddStaticVehicle(510,1697.1173,1413.8571,10.3509,293.6135,6,6);
	AddStaticVehicle(510,1697.9757,1409.3436,10.3476,294.1116,123,123);
	AddStaticVehicle(510,1698.9601,1405.2988,10.3225,292.0309,24,24);
	AddStaticVehicle(510,1700.3170,1400.5416,10.3176,288.0652,3,3);
	AddStaticVehicle(510,1702.4247,1396.1923,10.2938,295.0168,1,1);
	//������ - ������ ��������� LV
	AddStaticVehicle(510,2494.7903,1946.4784,10.4065,91.8290,6,6);
	AddStaticVehicle(510,2494.7275,1948.5835,10.4266,91.8296,3,3);
	AddStaticVehicle(510,2494.6558,1950.7406,10.4264,91.8296,4,4);
	return printf("[ServerLoad] LoadVehicles ���������� ��: %d ms", GetTickCount() - currenttime);
}
stock LoadOther()
{
	new currenttime = GetTickCount();
	
	//������ �����������
	for(new i; i < sizeof(BikeRent); i++)
	{
	    CreateDynamic3DTextLabel("�� ������� ����������?\n\n{ffffff}����������� {33aa33}/bike{ffffff}, �����\n���������� ��������� �� ������.", 0xD8A903FF, BikeRent[i][RentPos][0]-0.05, BikeRent[i][RentPos][1]-0.05, BikeRent[i][RentPos][2]+1.9, 7.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, 0, 0);
	    CreateDynamicPickup(1237, 1, BikeRent[i][RentPos][0], BikeRent[i][RentPos][1], BikeRent[i][RentPos][2], 0, 0);
	}
	//������� ����
	for(new i; i < sizeof(GreenZone); i++)
	{
		GreenZone[i][gZone] = CreateDynamicRectangle(GreenZone[i][gPos][0], GreenZone[i][gPos][1], GreenZone[i][gPos][2], GreenZone[i][gPos][3], GreenZone[i][gWorld], GreenZone[i][gInterior]);
	}
	//������
	for(new i; i < sizeof(Pickup); i++)
	{
		if(!GetString(Pickup[i][pText], "-")) CreateDynamic3DTextLabel(Pickup[i][pText], 0xFBEC5DFF, Pickup[i][pPos][0], Pickup[i][pPos][1], Pickup[i][pPos][2]+1.6, 6.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, Pickup[i][pVirtualWorld], Pickup[i][pInterior]);
		Pickup[i][pID] = CreateDynamicPickup(Pickup[i][pModel], 1, Pickup[i][pPos][0], Pickup[i][pPos][1], Pickup[i][pPos][2], Pickup[i][pVirtualWorld], Pickup[i][pInterior]);
	}
	//������ ��� ��������
	for(new i; i < sizeof(PTJob); i++)
	{
		PTJob[i][jLockerRoomPickupID] = CreateDynamicPickup(1275, 1, -2200.9893, 405.8916, 2166.0300, PTJob[i][jLockerRoomVirtualWorld], 17);
		PTJob[i][jCashPickupID] = CreateDynamicPickup(1239, 1, -2203.3623, 413.9457, 2166.0300, PTJob[i][jCashVirtualWorld], 17);
		CreateDynamicActor(150, -2201.3462, 414.0446, 2166.2390, 84.8916, true, 100.0, PTJob[i][jCashVirtualWorld], 17);
		CreateDynamic3DTextLabel("NPC {D8A903}������", 0xFFFFFFFF, -2201.3462, 414.0446, 2166.2390+1.1001, 7.0000, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, PTJob[i][jCashVirtualWorld], 17);
	}
	PTJobCP[0] = CreateDynamicCP(2638.9551, -2276.7654, 7.7059, 2.00);//������ �������� LS
	PTJobCP[1] = CreateDynamicCP(2617.4309, -2214.7158, 13.5469, 2.00);//������ �������� LS
	PTJobCP[2] = CreateDynamicCP(-1795.1847, -1648.5120, 31.2409, 2.00);//������ ������� SF
	PTJobCP[3] = CreateDynamicCP(-1818.4255, -1611.3439, 23.0880, 2.00);//������ ������� SF
	PTJobCP[4] = CreateDynamicCP(2430.4773, 1933.2249, 6.0156, 2.00);//������ ��������� LV
	PTJobCP[5] = CreateDynamicCP(2476.6304, 1929.5215, 10.4829, 2.00);//������ ��������� LV
	
	return printf("[ServerLoad] LoadOther ���������� ��: %d ms", GetTickCount() - currenttime);
}
stock LoadMap()
{
	new currenttime = GetTickCount();
   	CallRemoteFunction("LoadMaping", "");
	return printf("[ServerLoad] LoadMap ���������� ��: %d ms", GetTickCount() - currenttime);
}
stock LoadBusStop()
{
	new currenttime = GetTickCount(), object;
	
	for(new i; i < sizeof(BusStop); i++)
	{
		if(BusStop[i][City] == 0) object = 19171;
		else if(BusStop[i][City] == 1) object = 19170;
		else if(BusStop[i][City] == 2) object = 19169;
		BusStop[i][MiniMapObject] = CreateDynamicMapObject(object, BusStop[i][MiniMapPos][0], BusStop[i][MiniMapPos][1], BusStop[i][MiniMapPos][2], BusStop[i][MiniMapPos][3]);//������ ���������
		for(new d; d < 2; d++) BusStop[i][MiniMapPosObject][d] = CreatePointForDynamicMap(BusStop[i][MiniMapObject], 19256, 0.01);//������ ������� �������� �� ���������
	}

	return printf("[ServerLoad] LoadBusStop ���������� ��: %d ms", GetTickCount() - currenttime);
}
stock UpdateBusMap()
{
	new Float:vX, Float:vY, Float:vZ, carid, count, number, city;
	count = CallRemoteFunction("GetNPC_Count", "");
	for(new i; i < count; i++)
	{
    	carid = CallRemoteFunction("GetNPC_CarID", "i", i);
    	number = CallRemoteFunction("GetNPC_Number", "i", i);
    	city = CallRemoteFunction("GetNPC_City", "i", i);
	    GetVehiclePos(carid, vX, vY, vZ);
	    if(vX == 10000 || vY == 10000) continue;
	    for(new d; d < sizeof(BusStop); d++)
	    {
	        if(BusStop[d][City] != city) continue;
			MovePointForPos(BusStop[d][MiniMapPosObject][number], vX, vY);
	    }
	}
}
stock MySQLConnect()
{
	new currenttime = GetTickCount();
	gInfo[gMySQL] = mysql_connect(MYSQL_HOST, MYSQL_USER, MYSQL_DB, MYSQL_PASSWORD);
	switch(mysql_errno())
	{
		case 0, 1146: printf("����������� � ���� ������ �������");
	    case 1044: return print("����������� � ���� ������ �� �������, �������� ���� �����������! [������� �������������� ��� ������������]");
	    case 1045: return print("����������� � ���� ������ �� �������, �������� ���� �����������! [������ ������������ ������]");
	    case 1049: return print("����������� � ���� ������ �� �������, �������� ���� �����������! [������� �������������� ���� ������]");
	    case 2003: return print("����������� � ���� ������ �� �������, �������� ���� �����������! [������� � ����� ������ ����������]");
	    case 2005: return print("����������� � ���� ������ �� �������, �������� ���� �����������! [������ ������������ ����� ��������]");
	    default: return printf("����������� � ���� ������ �� �������, �������� ���� �����������! [����������� ������. ��� ������: %d]", mysql_errno());
	}
    printf("[ServerLoad] MySQL ���������� ��: %d ms", GetTickCount() - currenttime);
	return 1;
}
stock CreateTextDraws()
{
	#include ../library/TextDraws/Global/Other
	return 1;
}
stock CreatePlayerTextDraws(playerid)
{
	#include ../library/TextDraws/Player/Other
	return 1;
}
stock SetString(param_1[], param_2[], size = 300) return strmid(param_1, param_2, 0, strlen(param_2), size);
stock GetString(param_1[], param_2[], bool:ignorecase = false)
{
	if(!strlen(param_1) || !strlen(param_2)) return 0;
	return !strcmp(param_1, param_2, ignorecase);
}
stock GetTime(type)
{
    static time[40], number[3];
    new month, day, hour, minute;
    gettime(hour, minute, _); getdate(_, month, day);
    switch(day)
    {
        case 1, 21, 31: number = "st";
        case 2, 22: number = "nd";
        case 3, 23: number = "rd";
		default: number = "th";
    }
    if(type == 1) format(time, sizeof(time), "%02d:%02d", hour, minute);
    else if(type == 2)
	{
    	static const mtext[12][20] = {"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"};
		format(time, sizeof(time), "%d%s %s", day, number, mtext[month - 1]);
	}
    return time;
}
stock TalkDynamicActor(playerid)
{
	new actor = GetPlayerDynamicActorID(playerid);
	if(actor == -1) return 0;
	ApplyDynamicActorAnimation(gInfo[gDynamicActor][actor], "PED", "IDLE_CHAT", 4.0, 0, 0, 0, 0, 0);
	return 1;
}
stock EndTalkDynamicActor(playerid)
{
    TogglePlayerControllable(playerid, true);
	SetCameraBehindPlayer(playerid);
	return 1;
}
stock SetCameraToDynamicActor(playerid, actor, Float:distance = 1.5)
{
	new Float:pX, Float:pY, Float:pZ;
	new Float:aX, Float:aY, Float:aZ;
	GetPlayerPos(playerid, pX, pY, pZ);
	GetDynamicActorTurn(actor, aX, aY, aZ, distance, 180);
	InterpolateCameraPos(playerid, pX, pY, pZ+0.4, aX, aY, aZ+0.4, 1000);
	GetDynamicActorPos(actor, aX, aY, aZ);
	SetPlayerFacingPos(playerid, aX, aY);
	InterpolateCameraLookAt(playerid, pX, pY, pZ+0.4, aX, aY, aZ+0.4, 1000);
	TogglePlayerControllable(playerid, false);
	return 1;
}
stock GetDynamicActorTurn(actor, &Float:x, &Float:y, &Float:z, Float:distance, turn)
{
    new Float:angle,Float:dis;
    dis = dis/2 - distance;
    GetDynamicActorPos(actor, x, y, z),GetDynamicActorFacingAngle(actor, angle);
    x += (dis * floatsin(-angle+turn, degrees)),y += (dis * floatcos(-angle+turn, degrees));
    return 1;
}
stock SetPlayerFacingPos(playerid, Float:x, Float:y)
{// by Daniel_Cortez | pro-pawn.ru
    static Float:ax, Float:ay, Float:az;
    if(GetPlayerPos(playerid, ax, ay, az) == 0)
        return 0;
    return SetPlayerFacingAngle(playerid, atan2(y-ay, x-ax)-90.00);
}
stock GetPlayerDynamicActorID(playerid)
{
	new actor = -1;
	new Float:x, Float:y, Float:z;
	for(new i; i < sizeof(gInfo[gDynamicActor]); i++)
	{
		//if(!IsDynamicActorStreamedIn(gInfo[gDynamicActor][i], playerid)) continue;
		if(!IsValidDynamicActor(gInfo[gDynamicActor][i])) continue;
		if(GetDynamicActorVirtualWorld(gInfo[gDynamicActor][i]) != GetPlayerVirtualWorld(playerid)) continue;
		if(!gInfo[gDynamicActorTalk][i]) continue;
		GetDynamicActorPos(gInfo[gDynamicActor][i], x, y, z);
		if(!IsPlayerInRangeOfPoint(playerid, 5, x, y, z)) continue;
	//	actor = gInfo[gDynamicActor][i];
	    actor = i;
		break;
	}
	return actor;
}
stock GetPlayerBikeRentID(playerid)
{
	if(GetPlayerVirtualWorld(playerid) != 0 && GetPlayerInterior(playerid) != 0) return -1;
	new rent = -1;
	for(new i; i < sizeof(BikeRent); i++)
	{
		if(!IsPlayerInRangeOfPoint(playerid, 10, BikeRent[i][RentPos][0], BikeRent[i][RentPos][1], BikeRent[i][RentPos][2])) continue;
		rent = i;
		break;
	}
	return rent;
}
stock EnableGPS(playerid, Float:x, Float:y, Float:z)
{
	if(pInfo[playerid][tGPS] != -1) DisablePlayerCheckpoint(playerid);
	pInfo[playerid][tGPS] = SetPlayerCheckpoint(playerid, x, y, z, 3.0);
	return true;
}
stock RemoveObjectForPlayer(playerid)
{
	#include ../library/Map/remove
	return 1;
}
stock SettingSpawn(playerid)
{
    if(IsPlayerNPC(playerid)) return 1;
    if(pInfo[playerid][tLogged]) TogglePlayerControllable(playerid, true);
	new skin = pInfo[playerid][pSkin];
	if(pInfo[playerid][pCity] == 0) return SetSpawnInfoEx(playerid, skin, 1642.9904, -2239.6443, 13.4922, 180.3134);
	else if(pInfo[playerid][pCity] == 1) return SetSpawnInfoEx(playerid, skin, -1417.9692, -292.5034, 14.1484, 147.2435);
	else if(pInfo[playerid][pCity] == 2) return SetSpawnInfoEx(playerid, skin, 1676.5919, 1451.7231, 10.7840, 274.0734);
	return 1;
}

stock SetSpawnInfoEx(playerid, skin, Float:x, Float:y, Float:z, Float:a)
{
    return SetSpawnInfo(playerid, 255, skin, x, y, z-0.2, a, 0, 0, 0, 0, 0, 0);
}
stock OnPlayerRegister(playerid)
{
	format(gInfo[gString], 500, "INSERT INTO `accounts` (`NickName`, `Password`, `Level`, `Sex`, `Referal`, `Skin`, `City`) VALUES ('%s', MD5('%s'), '1', '%d', '%s', '%d', '%d')",
	PN(playerid),
	pInfo[playerid][tRegPassword],
	pInfo[playerid][tRegSex],
	pInfo[playerid][tRegReferal],
	RegSkins[pInfo[playerid][tRegSex]][pInfo[playerid][tRegSkin]],
	pInfo[playerid][tRegCity]);
	mysql_tquery(gInfo[gMySQL], gInfo[gString], "OnPlayerRegisterMysql", "d", playerid);
	return 1;
}
stock OnPlayerLogin(playerid)
{
    if(pInfo[playerid][tLogged]) return Kick(playerid);
    format(gInfo[gString], 400, "SELECT * FROM `accounts` WHERE `ID` = '%d' LIMIT 1", pInfo[playerid][pID]);
    mysql_tquery(gInfo[gMySQL], gInfo[gString], "OnPlayerLoginMysql", "d", playerid);
    return 1;
}
stock UpdatePlayerDataInt(const playerid, const field[], data)
{
	static const fmt_str[] = "UPDATE `accounts` SET `%s` = '%d' WHERE `ID` = '%d' LIMIT 1";
	static str[sizeof(fmt_str) - 6 + 64 + 64];
	str[0] = EOS;
	format(str, sizeof(str), fmt_str, field, data, pInfo[playerid][pID]);
	return mysql_tquery(gInfo[gMySQL], str);
}
stock UpdatePlayerDataFloat(const playerid, const field[], Float:data)
{
	static const fmt_str[] = "UPDATE `accounts` SET `%s` = '%f' WHERE `ID` = '%d' LIMIT 1";
	static str[sizeof(fmt_str) - 6 + 64 + 64];
	str[0] = EOS;
	format(str, sizeof(str), fmt_str, field, data, pInfo[playerid][pID]);
	return mysql_tquery(gInfo[gMySQL], str);
}
stock UpdatePlayerDataStr(const playerid, const field[], data[])
{
	static const fmt_str[] = "UPDATE `accounts` SET `%s` = '%q' WHERE `ID` = '%d' LIMIT 1";
	static str[sizeof(fmt_str) - 6 + 64 + 64];
	str[0] = EOS;
	format(str, sizeof(str), fmt_str, field, data, pInfo[playerid][pID]);
	return mysql_tquery(gInfo[gMySQL], str);
}
stock SelectRegCity(playerid, city)
{
	pInfo[playerid][tRegCity] = city;
	SetPlayerTime(playerid, CityInfo[city][CityHour], 0);
	TextDrawSetStringForPlayer(Select_City, playerid, CityInfo[city][CityName]);
	SetPlayerCameraPos(playerid, CityInfo[city][CityCamPos][0], CityInfo[city][CityCamPos][1], CityInfo[city][CityCamPos][2]);
	SetPlayerCameraLookAt(playerid, CityInfo[city][CityCamPos][3], CityInfo[city][CityCamPos][4], CityInfo[city][CityCamPos][5]);
	SetPlayerPos(playerid, CityInfo[city][CityCamPlayerPos][0], CityInfo[city][CityCamPlayerPos][1], CityInfo[city][CityCamPlayerPos][2]);
	SetPlayerFacingAngle(playerid, 0);
	return 1;
}
stock NullPlayer(playerid)
{
    for(new pinfo:e; e < pinfo; ++e) pInfo[playerid][e] = EOS;
	
    pInfo[playerid][tLoginAttempts] = 6;
    pInfo[playerid][tGPS] = -1;
    pInfo[playerid][tSelectedDynamicActor] = -1;
    pInfo[playerid][tBrightnessColor] = -1;
    pInfo[playerid][tBikeRent] = -1;
	pInfo[playerid][tCameraObject] = -1;
	pInfo[playerid][tPlaneObject] = -1;
	pInfo[playerid][tPTJob] = -1;
	
	SetPVarInt(playerid, "DialogID", -1);
	
	SetPlayerRussifierType(playerid, RussifierType_SanLtd);
	
	SetPlayerColor(playerid, 255);
	SetSpawnInfo(playerid, 255, 0, 0, 10, 0, 0, 0, 0, 0, 0, 0, 0);
	return 1;
}
stock PlayerStopSound(playerid)
{
	return PlayerPlaySound(playerid, 1188, 0.0, 0.0, 0.0);
}
stock ProxDetector(Float:radius, playerid, string[], color)
{
	if(!IsPlayerConnected(playerid)) return 0;
	new Float:X, Float:Y, Float:Z;
	GetPlayerPos(playerid, X, Y, Z);
	foreach(new i: Player)
	{
		if(!IsPlayerInRangeOfPoint(i, radius, X, Y, Z)) continue;
		if(GetPlayerVirtualWorld(i) != GetPlayerVirtualWorld(playerid)) continue;
		if(GetPlayerInterior(i) != GetPlayerInterior(playerid)) continue;
		SCM(i, color, string);
	}
	return 1;
}
stock AntiFlood(playerid)
{
	if(GetPVarInt(playerid,"antiflood_chat_block") > gettime())
	{
 		SCMf(playerid, COLOR_GREY, "����� ��������� ���������� ��������� � ��� ������� ��������� %d ���.", GetPVarInt(playerid,"antiflood_chat_block") - gettime());
	    return 1;
	}
	if(GetPVarInt(playerid,"antiflood_chat") > gettime())
	{
		SetPVarInt(playerid,"antiflood_chat_count", GetPVarInt(playerid,"antiflood_chat_count") + 1);
		if(GetPVarInt(playerid,"antiflood_chat_count") == 2)
		{
			SetPVarInt(playerid,"antiflood_chat_block", gettime() + 7);
			SetPVarInt(playerid,"antiflood_chat_count", 0);
		}
	}
	SetPVarInt(playerid,"antiflood_chat",gettime() + 2);
	return 0;
}
stock FindSymbol(text[], symbol)
{
	new symbols;
	for(new i; i < strlen(text); i++)
	{
	    if(text[i] != symbol) continue;
	    symbols++;
	}
	return symbols;
}
stock FindSymbols(text[], type)
{
    new symbols;
	for(new i; i < strlen(text); i++)
    {
		if(type == 0)//����� ���� � ������
		{
	        switch (text[i])
	        {
	            case ' ': continue;
	            case 'A'..'Z', 'a'..'z', '�'..'�', '�'..'�': continue;
	            default: symbols++;
	        }
		}
		else if(type == 1)//����� ���� � ������
		{
	        switch (text[i])
	        {
	            case ' ': continue;
	            case '0'..'9': continue;
	            default: symbols++;
	        }
		}
    }
    return symbols;
}
stock UpperCase(string[], length = -1)
{
	if(length == -1) length = strlen(string);
	for(new i; i < length; i ++)
	{
	    switch(string[i])
	    {
            case '�': string[i] = '�';
            case '�': string[i] = '�';
            case '�': string[i] = '�';
            case '�': string[i] = '�';
            case '�': string[i] = '�';
            case '�': string[i] = '�';
            case '�': string[i] = '�';
            case '�': string[i] = '�';
            case '�': string[i] = '�';
            case '�': string[i] = '�';
            case '�': string[i] = '�';
            case '�': string[i] = '�';
            case '�': string[i] = '�';
            case '�': string[i] = '�';
            case '�': string[i] = '�';
            case '�': string[i] = '�';
            case '�': string[i] = '�';
            case '�': string[i] = '�';
            case '�': string[i] = '�';
            case '�': string[i] = '�';
            case '�': string[i] = '�';
            case '�': string[i] = '�';
            case '�': string[i] = '�';
            case '�': string[i] = '�';
            case '�': string[i] = '�';
            case '�': string[i] = '�';
            case '�': string[i] = '�';
            case '�': string[i] = '�';
            case '�': string[i] = '�';
            case '�': string[i] = '�';
            case '�': string[i] = '�';
            case '�': string[i] = '�';
            default: string[i] = toupper(string[i]);
	    }
	}
}
stock SetPlayerRandomCamera(playerid)
{
	new r = random(sizeof(RandomCameraRequestClass));
	SetPlayerCameraPos(playerid, RandomCameraRequestClass[r][0], RandomCameraRequestClass[r][1], RandomCameraRequestClass[r][2]);
	SetPlayerCameraLookAt(playerid, RandomCameraRequestClass[r][3], RandomCameraRequestClass[r][4], RandomCameraRequestClass[r][5]);
	SetPlayerPos(playerid, RandomCameraRequestClass[r][6], RandomCameraRequestClass[r][7], RandomCameraRequestClass[r][8]);
	SetPlayerFacingAngle(playerid, RandomCameraRequestClass[r][9]);
	SetPlayerInterior(playerid, 0);
	return 1;
}
stock ObjectCameraPos(playerid, Float:from_x, Float:from_y, Float:from_z, Float:lock_x, Float:lock_y, Float:lock_z, Float:dest_x, Float:dest_y, Float:dest_z, Float:rotation, speed)
{
	if(pInfo[playerid][tCameraObject] != -1) DestroyPlayerObject(playerid, pInfo[playerid][tCameraObject]);
	TogglePlayerSpectating(playerid, true);
	SetPlayerCameraPos(playerid, from_x, from_y, from_z);
	SetPlayerCameraLookAt(playerid, lock_x, lock_y, lock_z);
    pInfo[playerid][tCameraObject] = CreatePlayerObject(playerid, 2995, from_x, from_y, from_z, 0.0, 0.0, 0.0);
	AttachCameraToPlayerObject(playerid, pInfo[playerid][tCameraObject]);
    MovePlayerObject(playerid, pInfo[playerid][tCameraObject], dest_x, dest_y, dest_z, speed, 0, 0, rotation);
	return 1;
}
stock ShowRegisterCutscene(playerid)
{
	if(pInfo[playerid][tCameraStage]) return 0;
	if(pInfo[playerid][tRegCity] == 0)
	{
		pInfo[playerid][tPlaneObject] = CreatePlayerObject(playerid, 1681, 1230.053, -2493.246, 74.791, 0.0, 0.0, 270.0);
	    SetTimerEx("PlaneMove", 300, false, "dfffdfff", playerid, 1501.924, -2494.117, 14.653, 60, 0.0, 0.0, 270.0);
		ObjectCameraPos(playerid, 1209.4299, -2526.9705, 78.3699, 1209.7421, -2493.1814, 79.2837, 1492.788, -2523.504, 16.025, 270.0, 60);
	}
	else if(pInfo[playerid][tRegCity] == 1)
	{
		pInfo[playerid][tPlaneObject] = CreatePlayerObject(playerid, 1681, -914.022, 578.205, 77.914, 0.0, 0.0, 135.0);
	    PlaneMove(playerid, -1366.208, 126.402, 15.275, 60, 0.0, 0.0, 135.0);
		ObjectCameraPos(playerid, -937.687, 605.526, 78.167, -872.1956, 384.4989, 47.7517, -1352.409, 179.643, 16.147, 0.0, 60);
	}
	else if(pInfo[playerid][tRegCity] == 2)
	{
		pInfo[playerid][tPlaneObject] = CreatePlayerObject(playerid, 1681, 1477.618, 852.137, 79.915, 0.0, 0.0, 0.0);
	    SetTimerEx("PlaneMove", 200, false, "dfffdfff", playerid, 1477.292, 1268.919, 11.977, 60, 0.0, 0.0, 0.0);
		ObjectCameraPos(playerid, 1500.628, 839.405, 81.991, 1477.6281, 839.4036, 81.9908, 1501.964, 1258.271, 14.178, 0.0, 60);
	}
	for(new i; i < 2; i++) TextDrawShowForPlayer(playerid, Black_Background[i]);
	pInfo[playerid][tCameraStage] = 1;
	return 1;
}
stock GiveMoney(playerid, money)
{
	if(!pInfo[playerid][tLogged]) return 0;
	
	pInfo[playerid][pMoney] += money;
	UpdatePlayerDataInt(playerid, "Money", pInfo[playerid][pMoney]);
	SetPlayerMoney(playerid, pInfo[playerid][pMoney]);

	if(!GetPVarInt(playerid, "ShowedBrightnessTextDraw"))
	{
		#include ../library/TextDraws/Player/GiveMoney

		format(gInfo[gString], 16, "%s%d $", (money >= 1) ? "~g~+" : "~r~-", (money >= 1) ? money:-money);
		PlayerTextDrawSetString(playerid, GiveMoney_Player[playerid], gInfo[gString]);
		
		ShowBrightnessTextDraw(playerid, 2, 1);
	}
	
	return 1;
}
stock SetPlayerMoney(playerid, money)
{
	ResetPlayerMoney(playerid);
	GivePlayerMoney(playerid, money);
	return 1;
}
stock PayDay()
{
	new hour, minute, second;
	gettime(hour, minute, second);
    SetWorldTime(hour);
	foreach(new i: Player)
	{
	    SCM(i, COLOR_GREEN, "������������� ������� ���������� ��� �� ��, ��� �� ��������� � ����.");
	}
	gInfo[tPayDay][hour] = true;
	if(hour == 0) for(new i = 1; i < 24; i++) gInfo[tPayDay][i] = false;
	else gInfo[tPayDay][hour - 1] = false;
	return 1;
}
stock ShowDescription(text[], var[])
{
	void description[120 + 1];
	SetString(description, text);
	new pos, insert_pos;
	for(new i; i < 3; i++)
	{
	    pos = 0;
		for(new d = insert_pos; d < sizeof(description); d++)
		{
			if(pos >= 24 && description[d] == ' ')
			{
				description[d] = '\n';
				insert_pos = d;
				break;
			}
		    pos++;
		}
	}
	SetString(var, description);
	return 1;
}
stock Freeze(playerid, time)
{
    TogglePlayerControllable(playerid, false);
    pInfo[playerid][tFreezeTime] = time;
	return 1;
}
stock PreloadAnimLib(playerid)
{
    ApplyAnimation(playerid,"BOMBER","null",0.0,0,0,0,0,0);
    ApplyAnimation(playerid,"RAPPING","null",0.0,0,0,0,0,0);
    ApplyAnimation(playerid,"SHOP","null",0.0,0,0,0,0,0);
    ApplyAnimation(playerid,"BEACH","null",0.0,0,0,0,0,0);
    ApplyAnimation(playerid,"SMOKING","null",0.0,0,0,0,0,0);
    ApplyAnimation(playerid,"FOOD","null",0.0,0,0,0,0,0);
    ApplyAnimation(playerid,"ON_LOOKERS","null",0.0,0,0,0,0,0);
    ApplyAnimation(playerid,"DEALER","null",0.0,0,0,0,0,0);
    ApplyAnimation(playerid,"CRACK","null",0.0,0,0,0,0,0);
    ApplyAnimation(playerid,"CARRY","null",0.0,0,0,0,0,0);
    ApplyAnimation(playerid,"COP_AMBIENT","null",0.0,0,0,0,0,0);
    ApplyAnimation(playerid,"PARK","null",0.0,0,0,0,0,0);
    ApplyAnimation(playerid,"INT_HOUSE","null",0.0,0,0,0,0,0);
    ApplyAnimation(playerid,"FOOD","null",0.0,0,0,0,0,0);
    ApplyAnimation(playerid,"CRIB","null",0.0,0,0,0,0,0);
    ApplyAnimation(playerid,"ROB_BANK","null",0.0,0,0,0,0,0);
    ApplyAnimation(playerid,"JST_BUISNESS","null",0.0,0,0,0,0,0);
    ApplyAnimation(playerid,"PED","null",0.0,0,0,0,0,0);
    ApplyAnimation(playerid,"OTB","null",0.0,0,0,0,0,0);
    SetPVarInt(playerid, "Animations", 1);
    return 1;
}
stock PTJobDialogStart(playerid, ptjobid)
{
	if(pInfo[playerid][tPTJob] != -1) return SPD(playerid, 44, DIALOG_STYLE_MSGBOX, " ", "{afafaf}�� ��� ����� �� �����, ����������� � �����, ���� ������ �������� ������.", "X", "");
	switch(ptjobid)
	{
	    //������ �������� LS
	    case 0:
	    {
	    	SPD(playerid, 202, DIALOG_STYLE_MSGBOX, "{34C924}������ � ��������� �����", "{ffffff}��� ��������� ������� ���� ��� ������ � ��������� �����.\n�� ������ ������������ ������� �� ������ �������� �� {33aa33}10 ${ffffff},\n�� ������������� ������ ������ ��� � ���������� � ������?", "��", "���");
	    }
	    //������ ������� SF
	    case 1:
	    {
	    	SPD(playerid, 202, DIALOG_STYLE_MSGBOX, "{34C924}������ �� ������", "{ffffff}��� ��������� ������� ���� ��� ������ � ������ �� ������.\n�� ������ ������������ �������� �� ������ �������� �� {33aa33}10 ${ffffff},\n�� ������������� ������ ������ ��� � ���������� � ������?", "��", "���");
	    }
	    //������ ��������� LV
	    case 2:
	    {
	    	SPD(playerid, 202, DIALOG_STYLE_MSGBOX, "{34C924}������ �� �������������", "{ffffff}��� ��������� ������� ���� ��� ������ � ������ �� �������.\n�� ������ ������������ ����� �� ������ �������� �� {33aa33}10 ${ffffff},\n�� ������������� ������ ������ ��� � ���������� � ������?", "��", "���");
	    }
	}
	SetPVarInt(playerid, "PTJobID", ptjobid);
	return 1;
}
stock PTJobDialogStarted(playerid, ptjobid)
{
	if(pInfo[playerid][tPTJob] != -1) return 0;
	if(pInfo[playerid][pPTJobCount] >= 50) return SPD(playerid, 44, DIALOG_STYLE_MSGBOX, " ", "{afafaf}�� ��������� ����������� ���������� ����� ������ ���������.", "X", "");
	switch(ptjobid)
	{
	    //������ �������� LS
	    case 0:
	    {
			SPD(playerid, 44, DIALOG_STYLE_MSGBOX, " ", "{9ACD32}�����������: ��������� � ������ ������� ������� ���������� �� ����� ������. ������������� ���� � �������� �������.", "X", "");
			TogglePlayerDynamicCP(playerid, PTJobCP[0], true);
	    }
	    //������ ������� SF
	    case 1:
	    {
	    	SPD(playerid, 44, DIALOG_STYLE_MSGBOX, " ", "{9ACD32}�����������: ���� �� ������� ���������� �������� ������� ���������� �� ����� ������. ������������� ���� � �������� ���� ����.", "X", "");
			TogglePlayerDynamicCP(playerid, PTJobCP[2], true);
	    }
	    //������ ��������� LV
	    case 2:
	    {
	    	SPD(playerid, 44, DIALOG_STYLE_MSGBOX, " ", "{9ACD32}�����������: ���� � ������� �������� ������� ���������� �� ����� ������. ������������� ���� � �������� ���� �����.", "X", "");
			TogglePlayerDynamicCP(playerid, PTJobCP[4], true);
	    }
	}
	SetPlayerSkin(playerid, (pInfo[playerid][pSex] == 1) ? 27 : 69);
	SetPVarInt(playerid, "PTJobCount", 0);
	pInfo[playerid][tPTJob] = ptjobid;
	DeletePVar(playerid, "PTJobID");
	return 1;
}
stock PTJobDialogEnd(playerid, ptjobid)
{
	if(pInfo[playerid][tPTJob] != ptjobid) return SPD(playerid, 44, DIALOG_STYLE_MSGBOX, " ", "{9ACD32}������: �� �� ��������� � ���. ������������� � ����������, ���� ������ ������ �����.", "X", "");
	switch(ptjobid)
	{
	    //������ �������� LS
	    case 0:
	    {
			new ptjobcount = GetPVarInt(playerid, "PTJobCount"), ptjobcounttext[10];
			if(!ptjobcount) return SPD(playerid, 203, DIALOG_STYLE_MSGBOX, "{34C924}�����", "{ffffff}�� �� ��������� �� ����� �������, �� ������������� ������ ���� �� �����?", "��", "���");
			else if(ptjobcount == 1) ptjobcounttext = "�������";
			else if(ptjobcount >= 2 && ptjobcount <= 4) ptjobcounttext = "�������";
			else ptjobcounttext = "�������";
			format(gInfo[gString], 170, "{ffffff}�� ������� ��� ���������� {D8A903}%d{ffffff} %s � ���������� {33aa33}%d ${ffffff}. �� ������ ���� �� ����� ����� ������ � ������� ������?", ptjobcount, ptjobcounttext, (10 * ptjobcount));
			SPD(playerid, 203, DIALOG_STYLE_MSGBOX, "{34C924}�����", gInfo[gString], "��", "���");
		}
	    //������ ������� SF
	    case 1:
	    {
			new ptjobcount = GetPVarInt(playerid, "PTJobCount"), ptjobcounttext[10];
			if(!ptjobcount) return SPD(playerid, 203, DIALOG_STYLE_MSGBOX, "{34C924}�����", "{ffffff}�� �� ��������� �� ����� ��������, �� ������������� ������ ���� �� �����?", "��", "���");
			else if(ptjobcount == 1) ptjobcounttext = "��������";
			else if(ptjobcount >= 2 && ptjobcount <= 4) ptjobcounttext = "��������";
			else ptjobcounttext = "��������";
			format(gInfo[gString], 170, "{ffffff}�� ������� ��� ��������� {D8A903}%d{ffffff} %s � ���������� {33aa33}%d ${ffffff}. �� ������ ���� �� ����� ����� ������ � ������� ������?", ptjobcount, ptjobcounttext, (10 * ptjobcount));
			SPD(playerid, 203, DIALOG_STYLE_MSGBOX, "{34C924}�����", gInfo[gString], "��", "���");
		}
	    //������ ��������� LV
	    case 2:
	    {
			new ptjobcount = GetPVarInt(playerid, "PTJobCount"), ptjobcounttext[10];
			if(!ptjobcount) return SPD(playerid, 203, DIALOG_STYLE_MSGBOX, "{34C924}�����", "{ffffff}�� �� ��������� �� ����� �����, �� ������������� ������ ���� �� �����?", "��", "���");
			else if(ptjobcount == 1) ptjobcounttext = "�����";
			else if(ptjobcount >= 2 && ptjobcount <= 4) ptjobcounttext = "�����";
			else ptjobcounttext = "�����";
			format(gInfo[gString], 170, "{ffffff}�� ������� ��� ��������� {D8A903}%d{ffffff} %s � ���������� {33aa33}%d ${ffffff}. �� ������ ���� �� ����� ����� ������ � ������� ������?", ptjobcount, ptjobcounttext, (10 * ptjobcount));
			SPD(playerid, 203, DIALOG_STYLE_MSGBOX, "{34C924}�����", gInfo[gString], "��", "���");
		}
	}
	return 1;
}
stock PTJobDialogEnded(playerid)
{
	if(pInfo[playerid][tPTJob] == -1) return 0;
	new ptjobcount = GetPVarInt(playerid, "PTJobCount");
	if(!ptjobcount)
	{
		SPD(playerid, 44, DIALOG_STYLE_MSGBOX, " ", "{9ACD32}������: �����. �������������, ���� ������ ���������� � ���.\n\n{fbec5d}�����: ��� ��������� �������� ������������� � ��� �������������. ������� {ffffff}/gps{fbec5d} ������� ����� ���.", "X", "");
		PTJobEnd(playerid);
		SetPVarInt(playerid, "PTJobEnded", 1);
		return 0;
	}
	format(gInfo[gString], 200, "{9ACD32}������: ������� ������� �� ������. �� ���������� %d $.\n\n{fbec5d}�����: ��� ��������� �������� ������������� � ��� �������������. ������� {ffffff}/gps{fbec5d} ������� ����� ���.", (10 * ptjobcount));
	SPD(playerid, 44, DIALOG_STYLE_MSGBOX, " ", gInfo[gString], "X", "");
	GiveMoney(playerid, (10 * ptjobcount));
	UpdatePlayerDataInt(playerid, "PTJobCount", pInfo[playerid][pPTJobCount]);
	PTJobEnd(playerid);
	SetPVarInt(playerid, "PTJobEnded", 1);
	return 1;
}
stock PTJobEnd(playerid)
{
	DeletePVar(playerid, "PTJobCount");
	DeletePVar(playerid, "PTJobObject");
	RemovePlayerAttachedObject(playerid, 0);
	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
	ClearAnim(playerid);
    for(new i; i < sizeof(PTJobCP); i++) TogglePlayerDynamicCP(playerid, PTJobCP[i], false);
    pInfo[playerid][tPTJob] = -1;
    ResetPlayerSkin(playerid);
    return 1;
}
stock SPD(playerid, dialogid, style, caption[], info[], button1[], button2[])
{
	SetPVarInt(playerid, "DialogID", dialogid);
	ShowPlayerDialog(playerid, dialogid, style, caption, info, button1, button2);
	return 1;
}
stock HPD(playerid)
{
	SPD(playerid, -1, 0, " ", " ", " ", " ");
	return 1;
}
stock ResetDynamicCPs(playerid)
{
    for(new i; i < sizeof(PTJobCP); i++) TogglePlayerDynamicCP(playerid, PTJobCP[i], false);
	return 1;
}
stock ResetPlayerSkin(playerid)
{
	//������, ��� ����, ����� �������� ���� ����� �� ������� � ���������������
    SetPlayerSkin(playerid, pInfo[playerid][pSkin]);
	return 1;
}
stock GetOtherPlayer(playerid, other_player[], Float:check_radius = 0.0, bool:check_npc = false)
{
	new number_id = -1;
	new number_players = 0;
	if(FindSymbols(other_player, 1))
	{
	    foreach(new i: Character)
	    {
		    if(strfind(PN(i),other_player,true) == -1) continue;
			number_id = i;
			number_players++;
		}
	}
	else if(FindSymbols(other_player, 0))
	{
		if(!IsPlayerConnected(strval(other_player))) number_id = -1;
		else
		{
			number_id = strval(other_player);
			number_players = 1;
		}
	}
	if(number_id == -1) SCM(playerid, COLOR_GREY, "�� ������� �� ������� ������� �� ��������� ���� ����������.");
	else if(number_players > 1)
	{
		SCM(playerid, COLOR_GREY, "�� ������� ������� ��������� ������� �� ��������� ���� ����������.");
        return -1;
	}
	if(number_id != -1 && number_players == 1)
	{
		if(!IsPlayerNPC(number_id) && !pInfo[number_id][tLogged])
		{
			SCM(playerid, COLOR_GREY, "��������� ���� ����� �� ���������.");
        	return -1;
		}
		if(check_npc && IsPlayerNPC(number_id))
		{
			SCM(playerid, COLOR_GREY, "��������� ���� ����� �������� �����.");
			return -1;
		}
	    if(check_radius > 0)
	    {
			new Float:pX, Float:pY, Float:pZ;
			GetPlayerPos(number_id, pX, pY, pZ);
		    if(!IsPlayerInRangeOfPoint(playerid, check_radius, pX, pY, pZ))
			{
				SCM(playerid, COLOR_GREY, "�� ������� ������ ���� �� �����.");
				return -1;
			}
		}
	}
	return number_id;
}
stock ShowBackgroundForPlayer(playerid, type = 0)
{
    if(!pInfo[playerid][tBackgroundBox])
    {
        Background_TD[playerid] = CreatePlayerTextDraw(playerid, -12.0000, -10.3555, "Box"); // �����
        PlayerTextDrawLetterSize(playerid, Background_TD[playerid], 0.0000, 53.6333);
        PlayerTextDrawTextSize(playerid, Background_TD[playerid], 680.0000, 0.0000);
        PlayerTextDrawUseBox(playerid, Background_TD[playerid], 1);
        PlayerTextDrawBoxColor(playerid, Background_TD[playerid], 255);

        pInfo[playerid][tBackgroundBox] = 0;
	    pInfo[playerid][tBackgroundTimer] = SetTimerEx("Background_Timer", 200, true, "ii", playerid, 1);
    }
    SetPVarInt(playerid, "BackgroundShowTD", type);
}

stock HideBackgroundForPlayer(playerid)
{
    if(pInfo[playerid][tBackgroundBox] > 0)
    {
        pInfo[playerid][tBackgroundBox] = 255;
	    pInfo[playerid][tBackgroundTimer] = SetTimerEx("Background_Timer", 200, true, "ii", playerid, 2);
    }
}
stock IsRPNick(const name[])
{ // http://pro-pawn.ru/showthread.php?7528
    static i, __;
    if ('A' <= name[0] <= 'Z' && 'a' <= name[1] <= 'z')
    {
        for (i = 1, __ = 0;;)
        {
            switch (name[++i])
            {
                case 'a'..'z':
                    continue;
                case '_':
                    if (__++, 'A' <= name[++i] <= 'Z' && 'a' <= name[++i] <= 'z')
                        continue;
                    else
                        break;
                case '\0':
                    return (i >= 4 && __ == 1);
                default:
                    return false;
            }
        }
    }
    return false;
}
//=============================[ ������� ]=============================//
CMD:talk(playerid)
{
	new actor = GetPlayerDynamicActorID(playerid);
	if(actor == -1) return SCM(playerid, COLOR_GREY, "���������� ��� �����, � �������� ����� �������� � ������.");
	SetCameraToDynamicActor(playerid, gInfo[gDynamicActor][actor]);
	TalkDynamicActor(playerid);
	pInfo[playerid][tSelectedDynamicActor] = actor;
    void actor_name[40];
    format(actor_name, sizeof(actor_name), "{ffffff}NPC {9ACD32}%s", ActorNames[actor]);
	switch(actor)
	{
	    case 0..2:
		{
		    format(gInfo[gString], 144, "\n\n{F5DEB3}-  %s:{ffffff} ������������, %s. � ����, ��� ����� ������. �� ������ �� ���������� �� ����?\n\n", ActorNames[actor], (pInfo[playerid][pSex] == 1) ? "������� �������" : "����� ����");
			SPD(playerid, 3830, DIALOG_STYLE_MSGBOX, actor_name, gInfo[gString], "��������", "��� ����");
		}
		case 3..5:
		{
			if(pInfo[playerid][tPTJob] != -1)
			{
   				new ptjobresourcename[10];
				if(pInfo[playerid][tPTJob] == 0) ptjobresourcename = "������";//������ �������� LS
				else if(pInfo[playerid][tPTJob] == 1) ptjobresourcename = "��������";//������ ������� SF
				else if(pInfo[playerid][tPTJob] == 2) ptjobresourcename = "�����";//������ ��������� LV
			    if(pInfo[playerid][pPTJobCount] < 5)
			    {
					format(gInfo[gString], 256, "\n\n{F5DEB3}-  %s:{ffffff} ����������� ��������. ��� ��������� ��������� ��� ������� {D8A903}5{ffffff} %s, ����� ���������� {33aa33}50 ${ffffff} �� ������ �����.\n\n", ActorNames[actor], ptjobresourcename);
					SPD(playerid, 46, DIALOG_STYLE_MSGBOX, actor_name, gInfo[gString], "X", "");
					return 1;
				}
				else
				{
					format(gInfo[gString], 256, "\n\n{F5DEB3}-  %s:{ffffff} �� ��������� ��� ���������� %s. ������������� � ����� � �������� ������, ������� ��� ������ �� ������ �����.\n\n", ActorNames[actor], ptjobresourcename);
					SPD(playerid, 46, DIALOG_STYLE_MSGBOX, actor_name, gInfo[gString], "X", "");
					return 1;
				}
			}
			format(gInfo[gString], 144, "\n\n{F5DEB3}-  %s:{ffffff} ������������. � ���� ��� ��� ���� �����. ������� ��� ���� �����?\n\n", ActorNames[actor]);
			SPD(playerid, 3840, DIALOG_STYLE_MSGBOX, actor_name, gInfo[gString], "��������", "��� ����");
		}
	}
	return 1;
}
CMD:bike(playerid)
{
    if(pInfo[playerid][tBikeRent] != -1) return SPD(playerid, 4491, DIALOG_STYLE_MSGBOX, "{34C924}����� �� ������", "{ffffff}�� ������������� ������ ���������� �� ������ ���������� � ������� ��� � ������?", "��", "���");
	new rent = GetPlayerBikeRentID(playerid);
	if(rent == -1) return SCM(playerid, COLOR_GREY, "���������� ��� ������� ������� �����������.");
	if(IsPlayerInAnyVehicle(playerid)) return SCM(playerid, COLOR_GREY, "�� �� ������ ��������������� ������� ������� � ������ ������.");
 	SPD(playerid, 4490, DIALOG_STYLE_MSGBOX, "{34C924}����� ������� �����������", "{ffffff}�� ������ ��������������� ����� �������� � ���������� ��������� ��������� ���������?", "��", "���");
	return 1;
}
CMD:clchat(playerid)
{
	for(new i; i < 30; i++) SCM(playerid, -1, " ");
	return 1;
}
CMD:delimeter(playerid)
{
	SCM(playerid, COLOR_GREEN, "_______________________________________________________________________________________________");
	return 1;
}
CMD:c(playerid, params[])
{
	if(sscanf(params, "s[145]", params)) return SCM(playerid, COLOR_GREY, "���������: /c [����� ���������]");
	return OnPlayerText(playerid, params);
}
CMD:s(playerid, params[])
{
	if(sscanf(params, "s[145]", params)) return SCM(playerid, COLOR_GREY, "���������: /s [����� ���������]");
	if(AntiFlood(playerid)) return 0;
	format(gInfo[gString], 160, "%s %s: %s", PN(playerid), (pInfo[playerid][pSex] == 1) ? "�������" : "��������", params);
	ProxDetector(20.0, playerid, gInfo[gString], COLOR_LIGHTBLUE);
	SetPlayerChatBubble(playerid, params, COLOR_LIGHTBLUE, 20.0, 10000);
	ApplyAnimation(playerid, "RIOT", "RIOT_shout", 4.1, 0, 0, 0, 0, 0);
	return 1;
}
CMD:w(playerid, params[])
{
	new player[MAX_PLAYER_NAME];
	if(sscanf(params, "s[24]s[145]", player, params)) return SCM(playerid, COLOR_GREY, "���������: /w [ID ��� ����� ����] [����� ���������]");
	if(AntiFlood(playerid)) return 0;
	new player_id = GetOtherPlayer(playerid, player, 2.5, true);
	if(player_id == -1) return 0;
	if(player_id == playerid) return SCM(playerid, COLOR_GREY, "�� �� ������ ������� ������ ����.");
	SCMf(playerid, 0x98FF98FF, "�� ������� %s: %s", PN(player_id), params);
	SCMf(player_id, 0x98FF98FF, "%s %s ���: %s", PN(playerid), (pInfo[playerid][pSex] == 1) ? "������" : "�������", params);
	return 1;
}
CMD:wh(playerid)
{
	if(GetPVarInt(playerid, "antiflood_whistling") > gettime()) return SendClientMessage(playerid, COLOR_GREY, "�� �� ������ �������� ��� �����.");
	format(gInfo[gString], 60, "%s %s.", PN(playerid), (pInfo[playerid][pSex] == 1) ? "��������" : "���������");
	ProxDetector(20.0, playerid, gInfo[gString], COLOR_LIGHTBLUE);
	ApplyAnimation(playerid, "RIOT", "RIOT_shout", 4.1, 0, 0, 0, 0, 0);
	SetPVarInt(playerid,"antiflood_whistling", gettime() + 5);
	return 1;
}
CMD:try(playerid, params[])
{
	if(sscanf(params, "s[145]", params)) return SCM(playerid, COLOR_GREY, "���������: /try [�������� ��������]");
	if(AntiFlood(playerid)) return 0;
	format(gInfo[gString], 160, "* * %s %s (%s)", PN(playerid), params, (random(2) == 0 ? "������" : "��������"));
	ProxDetector(10.0, playerid, gInfo[gString], COLOR_PURPLE);
	return 1;
}
CMD:me(playerid, params[])
{
	if(sscanf(params, "s[145]", params)) return SCM(playerid, COLOR_GREY, "���������: /me [�������� ��������]");
	if(strlen(params) >= 114) return SCM(playerid, COLOR_GREY, "�� ����� ������� ������� ����� �������� �������� � ������� �� ������ ������� ��� �� ��������� �����.");
	if(AntiFlood(playerid)) return 0;
	format(gInfo[gString], 160, "* %s %s", PN(playerid), params);
	ProxDetector(10.0, playerid, gInfo[gString], COLOR_PURPLE);
	UpperCase(params, 1);
	SetPlayerChatBubble(playerid, params, COLOR_PURPLE, 10.0, 10000);
	return 1;
}
CMD:ame(playerid, params[])
{
	if(sscanf(params, "s[145]", params)) return SCM(playerid, COLOR_GREY, "���������: /ame [�������� ��������]");
	SCMf(playerid, COLOR_PURPLE, "! %s %s", PN(playerid), params);
	UpperCase(params, 1);
	SetPlayerChatBubble(playerid, params, COLOR_PURPLE, 10.0, 10000);
	return 1;
}
CMD:do(playerid, params[])
{
	if(sscanf(params, "s[145]", params)) return SCM(playerid, COLOR_GREY, "���������: /do [�������� ��������]");
	if(strlen(params) >= 123) return SCM(playerid, COLOR_GREY, "�� ����� ������� ������� ����� �������� �������� � ������� �� ������ ������� ��� �� ��������� �����.");
	if(AntiFlood(playerid)) return 0;
	UpperCase(params, 1);
	if(strlen(params) >= 109)
	{
		format(gInfo[gString], 160, "* %s...", params);
		ProxDetector(10.0, playerid, gInfo[gString], COLOR_PURPLE);
		format(gInfo[gString], 40, "...(( %s ))", PN(playerid));
		ProxDetector(10.0, playerid, gInfo[gString], COLOR_PURPLE);
	}
	else
	{
		format(gInfo[gString], 160, "* %s (( %s ))", params, PN(playerid));
		ProxDetector(10.0, playerid, gInfo[gString], COLOR_PURPLE);
	}
	return 1;
}
CMD:b(playerid, params[])
{
	if(sscanf(params, "s[145]", params)) return SCM(playerid, COLOR_GREY, "���������: /b [����� ���������]");
	if(AntiFlood(playerid)) return 0;
	format(gInfo[gString], 145, "(( %s: %s ))", PN(playerid), params);
	ProxDetector(10.0, playerid, gInfo[gString], -1);
	format(gInfo[gString], 145, "(( %s ))", params);
	SetPlayerChatBubble(playerid, gInfo[gString], 0xDDDDDDFF, 10.0, 10000);
	return 1;
}
CMD:ab(playerid, params[])
{
	if(sscanf(params, "s[145]", params)) return SCM(playerid, COLOR_GREY, "���������: /ab [����� ���������]");
	SCMf(playerid, 0xDDDDDDFF, "! (( %s: %s ))", PN(playerid), params);
	format(gInfo[gString], 145, "(( %s ))", params);
	SetPlayerChatBubble(playerid, gInfo[gString], 0xDDDDDDFF, 10.0, 10000);
	return 1;
}
CMD:cdo(playerid, params[])
{
	static desc[145], text[145];
	if(sscanf(params, "s[145]", params)) return SCM(playerid, COLOR_GREY, "���������: /cdo [�������� �������� {33aa33}*{afafaf} ����� ���������]");
 	if(sscanf(params, "p<*>s[145]s[145]", desc, text)) return SCM(playerid, COLOR_GREY, "����������� ������ {33aa33}*{afafaf} ��� ���������� ������ � ��������.");
 	if(FindSymbol(params, '*') > 1) return SCM(playerid, COLOR_GREY, "�� ������ ������������ ������ ���� ������ {33aa33}*{afafaf} ��� ����������.");
 	if(strlen(params) > 107) return SCMf(playerid, COLOR_GREY, "�� ��������� ������������ ����� ������������� ��������� �� {33aa33}%d{afafaf} ������.", strlen(params) - 107);
	if(AntiFlood(playerid)) return 0;
	UpperCase(desc, 1);
	format(gInfo[gString], 160, "%s, %s %s: %s", desc, PN(playerid), (pInfo[playerid][pSex] == 1) ? "������" : "�������", text);
	ProxDetector(10.0, playerid, gInfo[gString], COLOR_GREEN);
	SetPlayerChatBubble(playerid, text, COLOR_GREEN, 10.0, 10000);
	return 1;
}
CMD:sdo(playerid, params[])
{
	static desc[145], text[145];
	if(sscanf(params, "s[145]", params)) return SCM(playerid, COLOR_GREY, "���������: /sdo [�������� �������� {33aa33}*{afafaf} ����� ���������]");
 	if(sscanf(params, "p<*>s[145]s[145]", desc, text)) return SCM(playerid, COLOR_GREY, "����������� ������ {33aa33}*{afafaf} ��� ���������� ������ � ��������.");
 	if(FindSymbol(params, '*') > 1) return SCM(playerid, COLOR_GREY, "�� ������ ������������ ������ ���� ������ {33aa33}*{afafaf} ��� ����������.");
 	if(strlen(params) > 107) return SCMf(playerid, COLOR_GREY, "�� ��������� ������������ ����� ������������� ��������� �� {33aa33}%d{afafaf} ������.", strlen(params) - 107);
	if(AntiFlood(playerid)) return 0;
	UpperCase(desc, 1);
	format(gInfo[gString], 160, "%s, %s %s: %s", desc, PN(playerid), (pInfo[playerid][pSex] == 1) ? "�������" : "��������", text);
	ProxDetector(20.0, playerid, gInfo[gString], COLOR_LIGHTBLUE);
	SetPlayerChatBubble(playerid, text, COLOR_LIGHTBLUE, 20.0, 10000);
	ApplyAnimation(playerid, "RIOT", "RIOT_shout", 4.1, 0, 0, 0, 0, 0);
	return 1;
}
CMD:todo(playerid, params[]) return callcmd::cdo(playerid, params);
CMD:coin(playerid)
{
	if(AntiFlood(playerid)) return 0;
	if(!pInfo[playerid][pMoney]) return SCM(playerid, COLOR_GREY, "� ��� ��� �����");
	format(gInfo[gString], 160, "%s %s �������. �������� ���������: {ffffff}%s{ffcc00}.", PN(playerid), (pInfo[playerid][pSex] == 1) ? "���������" : "����������", (random(2) == 0 ? "���" : "�����"));
	ProxDetector(10.0, playerid, gInfo[gString], COLOR_YELLOW);
	return 1;
}
CMD:desc(playerid)
{
	if(!strlen(pInfo[playerid][pDescription])) format(gInfo[gString], 64, "�� �����������");
	else format(gInfo[gString], 120 + 1, "%s", pInfo[playerid][pDescription]);
	format(gInfo[gString], 512, "\
	{D8A903}������� ��������:\n\
	%s\n\
	{D8A903}��������� ��������:\n\n\
	��c�� #1: �� �����������\n\
	��c�� #2: �� �����������\n\
	��c�� #3: �� �����������\n\
	��c�� #4: �� �����������\n\
	{D8A903}������������ ���������� ��������", gInfo[gString]);
	SPD(playerid, 7650, DIALOG_STYLE_LIST, "{34C924}�������� ������ ���������", gInfo[gString], "�����", "�����");
	return 1;
}
CMD:id(playerid, params[])
{
	new type_search = 1, player = -1;
	if(sscanf(params, "s[24]", params)) return SCM(playerid, COLOR_GREY, "���������: /id [����� ����]");
    if((params[0] >= 'a' && params[0] <= 'z') || (params[0] >= 'A' && params[0] <= 'Z')) type_search = 2;
    if(type_search == 1 && IsPlayerConnected(strval(params)))
    {
    	player = strval(params);
		SCMf(playerid, 0xFBEC5DFF, "��� {ffffff}%s{fbec5d} ID {ffffff}%d%s", PN(player), player, (GetTickCount() - pInfo[player][tAFK] > 1200) ? " {34C924}< AFK >" : "");
    }
    foreach(new i: Character)
    {
        if(type_search != 2) break;
	    if(strfind(PN(i),params,true) == -1) continue;
	    SCMf(playerid, 0xFBEC5DFF, "��� {ffffff}%s{fbec5d} ID {ffffff}%d%s", PN(i), i, (GetTickCount() - pInfo[i][tAFK] > 1200) ? " {34C924}< AFK >" : "");
	    player++;
    }
    if(player == -1) return SCM(playerid, COLOR_GREY, "�� ������� �� ������� ������� �� ��������� ���� ����������.");
	return 1;
}
CMD:getskin(playerid, params[])
{
	if(sscanf(params, "s[24]", params)) return SCMf(playerid, -1, "�� ����������� ���� {FBEC5D}#%d{FFFFFF}.", GetPlayerSkin(playerid));
	new player_id = GetOtherPlayer(playerid, params, 10.0);
	if(player_id == -1) return 0;
	SCMf(playerid, -1, "����� {ABCDEF}%s{FFFFFF} ���������� ���� {FBEC5D}#%d{FFFFFF}.", PN(player_id), GetPlayerSkin(player_id));
	return 1;
}
CMD:pay(playerid, params[])
{
	new player[MAX_PLAYER_NAME], money;
	if(sscanf(params, "s[24]d", player, money)) return SCM(playerid, COLOR_GREY, "���������: /pay [ID ��� ����� ����] [�����]");
	new player_id = GetOtherPlayer(playerid, player, 2.5, true);
	if(player_id == -1) return 0;
	if(player_id == playerid) return SCM(playerid, COLOR_GREY, "������ ���������� ������ ������ ����.");
	if(money < 1) return SCM(playerid, COLOR_GREY, "����� �� ����� ���� ������ {33AA33}1 $.");
	if(money > 9999) return SCM(playerid, COLOR_GREY, "�� �� ������ ���������� ����� ���������� �����, ����������� ���������� �������.");
	if(pInfo[playerid][pMoney] < money) return SCM(playerid, COLOR_GREY, "� ��� ��� ����� �����.");
	SCMf(playerid, -1, "�� ������� �� ������� ���� ������� � �������� {abcdef}%s {33aa33}%d ${ffffff}.", PN(player_id), money);
	SCMf(player_id, -1, "����� {abcdef}%s{ffffff} ������ �� ������� ���� ������� � ������� ��� {33aa33}%d ${ffffff}.", PN(playerid), money);
	GiveMoney(playerid, -money);
	GiveMoney(player_id, money);
	ApplyAnimation(playerid, "GHANDS", "gsign3LH", 4.1, 0, 1, 1, 1, 1);
	PlayerPlaySound(player_id, 1054, 0.0, 0.0, 0.0);
	SetTimerEx("ClearAnim", 2000, false, "d", playerid);
	return 1;
}
