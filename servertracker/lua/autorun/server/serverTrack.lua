require( "mysqloo" )
util.AddNetworkString( "TESTY" )
AddCSLuaFile( "cl_dermastuff.lua" )
include( "cl_dermastuff.lua" )


---- UPDATE ME
local SERVER_IP = "localhost"
local SERVER_PORT = 27015
local MAX_PLAYERS = 18

STATUS_READY    = mysqloo.DATABASE_CONNECTED;
STATUS_WORKING  = mysqloo.DATABASE_CONNECTING;
STATUS_OFFLINE  = mysqloo.DATABASE_NOT_CONNECTED;
STATUS_ERROR    = mysqloo.DATABASE_INTERNAL_ERROR;


local DATABASE_HOST = "50.116.87.115"
local DATABASE_PORT = 3306
local DATABASE_NAME = "jonzky_sb"
local DATABASE_USERNAME = "jonzky_jonzky"
local DATABASE_PASSWORD = "123spam123"

function connectToDatabase()

	db = mysqloo.connect(DATABASE_HOST, DATABASE_USERNAME, DATABASE_PASSWORD, DATABASE_NAME, DATABASE_PORT)
	db.onConnected = function() 
		print("[Awesome Tracker]******************Database linked!******************************") 
	    automaticretry = nil;
		databaseFailed = false;
		loadServerStats();
	end
	db.onConnectionFailed = function(self, err)
		databaseFailed = true;
		print("[Awesome Tracker]Failed to connect to the database: ", err, ". Retrying in 60 seconds.");
		automaticretry = true;	
		timer.Simple(60, self.connect, self);
	end
	db:connect()
end
hook.Add( "Initialize", "connectToDatabaseServerT", connectToDatabase ); 
 
 
function checkQuery(query)
    local playerInfo = query:getData()
    if playerInfo[1] ~= nil then
		return true
    else
		return false
    end
end 

-- From Lexic's SB module.
function CheckStatus()
    if (not db or automaticretry) then return; end
    local status = db:status();
    if (status == STATUS_WORKING or status == STATUS_READY) then
        return;
    elseif (status == STATUS_ERROR) then
        print("[Awesome Tracker]The database object has suffered an inernal error and will be recreated.");
        connectToDatabase();
    else
		print(status);
		db:abortAllQueries();
        print("[Awesome Tracker]The server has lost connection to the database. Retrying...")
        db:connect();
    end
end
timer.Create("Servberstatschecker", 60, 0, CheckStatus);


function getPlyCount()

	local i = 0;
	for k,v in pairs(player.GetAll()) do
		i = i + 1;
	end
	return i;

end

function loadServerStats( )

	lHost = GetConVarString("hostname");
	ipPort = string.format("%s:%s", SERVER_IP, SERVER_PORT);
	currentMap = game.GetMap();

    local Statquery1 = db:query("SELECT * FROM server_track WHERE hostip = '" .. ipPort .. "'")
	    
	Statquery1.onError = function(q,e)
		print("[Awesome Tracker]Something went wrong")
		print(e)
	end
	
	Statquery1.onSuccess = function(q)
        if not checkQuery(q) then

			local Statquery2 = db:query("INSERT INTO server_track(hostip, hostname, maxplayers, map, players, lastupdate) VALUES ('" .. ipPort .. "', '" .. lHost .. "', '" .. MAX_PLAYERS .. "', '" .. currentMap .. "', '" .. getPlyCount() .. "', '" .. os.time() .. "')")

			Statquery2.onSuccess = function(q)  
			
				print("[Awesome Tracker]Added this server to the table!") 
				
				playerCount = getPlyCount();
				
			end
			Statquery2.onError = function(q,e) 
				print("[Awesome Tracker]Something went wrong")
				print(e)
			end
			Statquery2:start()
		end	
		updateReady = true
	end 
	Statquery1:start()

	
end


function updateServers ()
	
	if not updateReady then return; end
	if databaseFailed then return; end

	updateString = "UPDATE server_track SET hostname='%s', maxplayers='%d', map='%s', players='%d', lastupdate='%d' WHERE hostip ='%s'"		
	local formQ = string.format(updateString,
					GetConVarString("hostname"),
					MAX_PLAYERS,
					game.GetMap(),
					getPlyCount(),
					os.time(),
					ipPort
				)
	
	local updateQuery = db:query(formQ)
	updateQuery.onSuccess = function(q) end; 
	updateQuery.onError = function(q,e)
		print("[Awesome Tracker]Something went wrong")
		print(e)
	end
	updateQuery:start()	

end
timer.Create("serverUpdaterTracker", 15, 0, updateServers);


function getServers(ply)

	if databaseFailed then
		ply:PrintMessage( HUD_PRINTTALK, "The server browser is currently unavailable - please try again soon");
		return
	end	
	
	local getAllQ = db:query( "SELECT * FROM server_track")
    getAllQ.onSuccess = function(q, sdata)
		net.Start( "TESTY")
			net.WriteTable(sdata)
			net.WriteFloat(os.time())
		net.Send(ply)
	end
	getAllQ.onError = function(q,e)
		print("[Awesome Tracker]Something went wrong")
		print(e)
	end
	getAllQ:start()
end
hook.Add("ShowSpare2", "SuperMANBroswer", getServers)	