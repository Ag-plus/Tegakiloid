--
-- Tegakiloid.lua
-- スマートフォンと連携した手書きコントロールパラメータ設定Plugin.
--

--
-- Copyright (C) 2011-2012 Ag+
--

--
-- プラグインマニフェスト関数.
--
function manifest()
	myManifest = {
		name          = "TEGAKILOID",
		comment       = "スマートフォンと連携してコントロールパラメータを設定します",
		author        = "Ag+_111",
		pluginID      = "{39951749-9DDE-4d4d-A23C-14222381693D}",
		pluginVersion = "1.0.0.2",
		apiVersion    = "3.0.0.1"
	}
	
	return myManifest
end

--
-- VOCALOID3 Jobプラグインスクリプトのエントリポイント.
--
function main(processParam, envParam)
	-- 実行時に渡された処理条件パラメータを取得します.
	local beginPosTick = processParam.beginPosTick	-- 選択範囲の始点時刻（ローカルTick）.
	local endPosTick   = processParam.endPosTick	-- 選択範囲の終点時刻（ローカルTick）.
	local songPosTick  = processParam.songPosTick	-- カレントソングポジション時刻（ローカルTick）.

	-- 実行時に渡された実行環境パラメータを取得します.
	local scriptDir  = envParam.scriptDir	-- Luaスクリプトが配置されているディレクトリパス（末尾にデリミタ "\" を含む）.
	local scriptName = envParam.scriptName	-- Luaスクリプトのファイル名.
	local tempDir    = envParam.tempDir		-- Luaプラグインが利用可能なテンポラリディレクトリパス（末尾にデリミタ "\" を含む）.

	--ローカルパラメータ
	local control = {}
	local controlMin = 0
	local controlMax = 128
	local magnification = 1
	local controlParam
	local indexMax
	local port
	local socket
	local server
	local recvmsg
	local retCode
	local index
	local width
	local height
	local posX
	local posY
	local table
	local dlgStatus
	local field = {}
	
	-- パラメータ入力ダイアログのウィンドウタイトルを設定します.
	VSDlgSetDialogTitle("ご使用のスマートフォンの画面サイズと通信用ポート番号を入力してください。")
	
	-- ダイアログにフィールドを追加します.
	field.name       = "height"
	field.caption    = "縦"
	field.initialVal = "800"
	field.type       = 0
	dlgStatus = VSDlgAddField(field)
	
	field.name       = "width"
	field.caption    = "横"
	field.initialVal = "480"
	field.type       = 0
	dlgStatus = VSDlgAddField(field)
	
	field.name       = "port"
	field.caption    = "ポート番号(1024以上で未使用のもの)"
	field.initialVal = "3939"
	field.type       = 3
	dlgStatus = VSDlgAddField(field)
	
	field.name       = "controlParam"
	field.caption    = "コントロールパラメータタイプ"
	field.initialVal =
		"DYN" ..
		",BRE" ..
		",BRI" ..
		",CLE" ..
		",GEN" ..
		",PIT" ..	-- -8192～+8191
		",PBS" ..	-- 0～24
		",POR"
	field.type = 4
	dlgStatus  = VSDlgAddField(field)
	
	-- パラメータ入力ダイアログを表示します.
	dlgStatus = VSDlgDoModal()
	if  (dlgStatus ~= 1) then
		-- OKボタンが押されなかったら終了します.
		return 1
	end
	
	-- パラメータ入力ダイアログから入力値を取得します.
	dlgStatus, width = VSDlgGetIntValue("width")
	dlgStatus, height = VSDlgGetIntValue("height")
	dlgStatus, port = VSDlgGetStringValue("port")
	dlgStatus, controlParam = VSDlgGetStringValue("controlParam")
	
	--コントロールパラメータ最大値調整
	if  (controlParam == "PIT") then
		controlMax = 8191
		magnification = 2
	elseif  (controlParam == "PBS") then
		controlMax = 24
	end
	
	--選択範囲量算出
	indexMax = endPosTick - beginPosTick
	
	--UDP信号受信準備
	socket = require("socket")
	server = socket.udp()
	server:setsockname("*", port)
	
	-- 先頭信号受信
	recvmsg, retCode = server:receive()
	
	--受信コードが"end"になるまで繰り返し
	--送信側で入力完了時に"end"を送るようにすること
	while(recvmsg ~= "end")  do
		--入力信号の解析
		table = { string.match(recvmsg, "([0-9.]+)%s([0-9.]+)") }
		posX = table[1]
		posY = table[2]
		
		--maxindexとスマートフォンの横幅から更新するindexを算出
		index = math.floor(indexMax / width * posX)
		
		--タッチポイントの設定パラメータを取得
		retCode, control.value = VSGetControlAt(controlParam, beginPosTick + index)
		
		--controlパラメータを更新
		control.value = math.floor((1 - (posY / height) * magnification) * controlMax)
		
		--タッチポイントのindexに対応するTickのパラメータを更新
		retCode = VSUpdateControlAt(controlParam, index, control.value)
		
		--次信号受信
		recvmsg, err = server:receive()
	end
	
	server:close()
	
	-- 正常終了.
	return 0
end
