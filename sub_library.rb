#! ruby -Ks
# -*- mode:ruby; coding:shift_jis -*-
$KCODE='s'

#==============================================================================
#Project Name    : BeatSaber Movie Cut TOOL
#File Name       : bs_movie_cut.rb  _frm_bs_movie_cut.rb  sub_library.rb
#                : dialog_gui.rb  main_gui_event.rb  main_gui_sub.rb
#                : language_en.rb  language_jp.rb
#Creation Date   : 2020/01/08
# 
#Copyright       : 2020 Rynan. (Twitter @rynan4818)
#License         : LGPL
#Tool            : ActiveScriptRuby(1.8.7-p330)
#                  https://www.artonx.org/data/asr/
#                  FormDesigner for Project VisualuRuby Ver 060501
#                  https://ja.osdn.net/projects/fdvr/
#RubyGems Package: rubygems-update (1.8.21)      https://rubygems.org/
#                  json (1.4.6 x86-mswin32)
#                  sqlite3 (1.3.3 x86-mswin32-60)
#==============================================================================

#SJIS �� UTF-8�ϊ�#
def utf8cv(str)
  if str.kind_of?(String)                       #�����ɓn���ꂽ���e��������̏ꍇ�̂ݕϊ�����������
    return NKF.nkf('-w --ic=CP932 -m0 -x',str)  #NKF���g����SJIS��UTF-8�ɕϊ����ĕԂ�
  else
    return str                                  #������ȊO�̏ꍇ�͂��̂܂ܕԂ�
  end
end

#UTF-8 �� SJIS�ϊ�#
def sjiscv(str)
  if str.kind_of?(String)                       #�����ɓn���ꂽ���e��������̏ꍇ�̂ݕϊ�����������
    return NKF.nkf('-W --oc=CP932 -m0 -x',str)  #NKF���g����UTF-8��SJIS�ɕϊ����ĕԂ�
  else
    return str                                  #������ȊO�̏ꍇ�͂��̂܂ܕԂ�
  end
end


#�z����̑S�Ă̕�����̕����R�[�h��(UTF-8 �� SJIS�ϊ�)�ύX����#
#�ċA�����ŁA�z����̔z��ɂ��镶������S�ĕϊ�����
def array_sjiscnv(data)
  ar = []                                       #�ϊ���̔z���p�ӂ���
  if data.kind_of?(Array)                       #�����ɓn���ꂽ���e���z��̏ꍇ�́A�z���W�J����(�z��ȊO���n���ꂽ�ꍇ�ɃG���[�ɂȂ�̂ŕK�v)
    data.each do |a|                            #�z���W�J���āA��Â�a�Ɏ��o���ČJ��Ԃ�����������
      if a.kind_of?(Array)                      #�W�J���ꂽ���e���A�X�ɔz��̏ꍇ�͍ċA�����ŕϊ���������
        ar.push array_sjiscnv(a)                #�ċA�����Ŏ������g(array_sjiscnv)���Ăяo���āA�����ϊ����ʂ�ϊ���̔z��̖����ɒǉ�����
      else
        ar.push sjiscv(a)                       #UTF-8 �� SJIS�ϊ��������ʂ�ϊ���̔z��̖����ɒǉ�����
      end
    end
  else
    ar.push sjiscv(a)                           #�z��ȊO�̏ꍇ�͕ϊ����ʂ�ϊ���̔z��̖����ɒǉ�����
  end
  return ar                                     #�ϊ���̔z���Ԃ�
end

#�z����̑S�Ă̕�����̕����R�[�h(SJIS �� UTF-8�ϊ�)�ύX#
#�ċA�����ŁA�z����̔z��ɂ��镶������S�ĕϊ�����
def array_utf8cnv(data)
  ar = []                                       #�ϊ���̔z���p�ӂ���
  if data.kind_of?(Array)                       #�����ɓn���ꂽ���e���z��̏ꍇ�́A�z���W�J����(�z��ȊO���n���ꂽ�ꍇ�ɃG���[�ɂȂ�̂ŕK�v)
    data.each do |a|                            #�z���W�J���āA��Â�a�Ɏ��o���ČJ��Ԃ�����������
      if a.kind_of?(Array)                      #�W�J���ꂽ���e���A�X�ɔz��̏ꍇ�͍ċA�����ŕϊ���������
        ar.push array_utf8cnv(a)                #�ċA�����Ŏ������g(array_utf8cnv)���Ăяo���āA�����ϊ����ʂ�ϊ���̔z��̖����ɒǉ�����
      else
        ar.push utf8cv(a)                       #SJIS �� UTF-8�ϊ��������ʂ�ϊ���̔z��̖����ɒǉ�����
      end
    end
  else
    ar.push utf8cv(a)                           #�z��ȊO�̏ꍇ�͕ϊ����ʂ�ϊ���̔z��̖����ɒǉ�����
  end
  return ar                                     #�ϊ���̔z���Ԃ�
end

###�t�@�C���̃^�C���X�^���v���~���b�擾
def get_file_timestamp(file)
  #�t�@�C���̃^�C���X�^���v���~���b�Ŏ擾���邽��WIN32API���g�p����
  create_file              = Win32API.new('kernel32', 'CreateFile', 'PIIIIII', 'I')
  get_file_time            = Win32API.new('kernel32', 'GetFileTime', 'IPPP', 'I')
  close_handle             = Win32API.new('kernel32', 'CloseHandle', 'I', 'I')
  file_time_to_system_time = Win32API.new('kernel32', 'FileTimeToSystemTime', 'PP', 'I')

  # �\���̂�Ԃ��Ă��炤�ꏊ���m��
  lp_creation_time    = "\0" * 4 * 2  # FILETIME = DWORD * 2
  lp_last_access_time = "\0" * 4 * 2  # FILETIME = DWORD * 2
  lp_last_write_time  = "\0" * 4 * 2  # FILETIME = DWORD * 2
  lp_system_time      = "\0" * 2 * 8  # SYSTEMTIME = WORD * 8

  h_file = create_file.call(file, 0x80000000, 0, 0, 3, 0, 0)
  get_file_time.call(h_file, lp_creation_time, lp_last_access_time, lp_last_write_time)
  close_handle.call(h_file)

  #�쐬����
  file_time_to_system_time.call(lp_creation_time, lp_system_time)
  year, mon, wday, day, hour, min, sec, msec =  lp_system_time.unpack('S8')
  create_time =  Time.gm(year, mon, day, hour, min, sec).to_i * 1000 + msec

  #�ŏI�A�N�Z�X����
  file_time_to_system_time.call(lp_last_access_time, lp_system_time)
  year, mon, wday, day, hour, min, sec, msec =  lp_system_time.unpack('S8')
  access_time = Time.gm(year, mon, day, hour, min, sec).to_i * 1000 + msec

  #�ŏI�������ݎ���
  file_time_to_system_time.call(lp_last_write_time, lp_system_time)
  year, mon, wday, day, hour, min, sec, msec =  lp_system_time.unpack('S8')
  write_time = Time.gm(year, mon, day, hour, min, sec).to_i * 1000 + msec
  return([create_time,access_time,write_time])
end

###beatsaber�̃f�[�^�x�[�X���J������###
def db_open
  #�f�[�^�[�x�[�X�̃I�[�v������
  begin                                               #��O����(begin�`rescue���ŃG���[�����������ꍇ��rescue�̏��������s�����
    if $ascii_mode
      #SQLite3�̃f�[�^�x�[�X(*.db)���J���ăC���X�^���X�ϐ�@db�ŃA�N�Z�X�ł���悤�ɂ���B
      @db = SQLite3::Database.new($beatsaber_dbfile)
    else
      #�t�@�C�������S�p����������̂�UTF-8�ɕϊ����ēn��
      @db = SQLite3::Database.new(utf8cv($beatsaber_dbfile))  
    end
  rescue Exception => e                               #�G���[���e��e�ɓ���
    if e.inspect =~ /unable to open database file/    #�G���[���e���f�[�^�x�[�X���J���Ȃ����e�̏ꍇ
      messageBox("#{DB_OPEN_ERROR_MES}\r\n#{$beatsaber_dbfile}",DB_OPEN_ERROR_TITLE,48)
    else
      messageBox(DB_ERROR_MES + e.inspect,DB_ERROR_TITLE,16)
    end
  end
end

def db_close
  @db.close
end

def db_column_check(table,column,type)
  #�f�[�^�x�[�X�̃J�����`�F�b�N
  sql = "PRAGMA table_info('#{table}');"
  fields, *rows = @db.execute2(sql)
  column_check = true
  rows.each do |row|
    if column == row[fields.index('name')]
      column_check = false
      break
    end
  end
  if column_check && rows.size > 0
    sql = "ALTER TABLE #{table} ADD COLUMN #{column} #{type};"
    @db.execute(sql)
  end
end

def db_check
  #�f�[�^�x�[�X�`�F�b�N
  db_open
  sql = "CREATE TABLE IF NOT EXISTS MovieOriginalTime(" +
        "filename TEXT NOT NULL PRIMARY KEY," +
        "create_time INTEGER NOT NULL," +
        "access_time INTEGER NOT NULL," +
        "write_time INTEGER NOT NULL);"
  @db.execute(sql)
  sql = "CREATE TABLE IF NOT EXISTS MovieCutFile(" +
        "datetime INTEGER NOT NULL," +
        "startTime INTEGER NOT NULL," +
        "out_dir TEXT NOT NULL," +
        "filename TEXT NOT NULL," +
        "stoptime INTEGER NOT NULL);"
  @db.execute(sql)
  db_column_check('MovieCutRecord','levelId','TEXT')
  db_column_check('NoteScore','beforeScore','INTEGER')
  @db.close
end

def db_execute(sql,db_open_flag = true,db_close_flag = true,no_table_mes = true)
  #�f�[�^�x�[�XSQL���s
  db_open if db_open_flag
  begin
    if $ascii_mode
      fields, *rows = @db.execute2(sql)
    else
      fields, *rows = array_sjiscnv(@db.execute2(utf8cv(sql)))
    end
  rescue Exception => e
    @db.close if db_close_flag
    if e.inspect =~ /no such table/
      messageBox(DB_NOPLAY_RECORD, DB_NOPLAY_RECORD_TITLE, 48) if no_table_mes
      return "no_table" unless no_table_mes
    else
      messageBox(DB_ERROR_MES + e.inspect, DB_ERROR_TITLE, 16)
    end
    return false
  end
  @db.close if db_close_flag
  return [fields,rows]
end

def file_name_check(file_name)
  if $ascii_mode
    $KCODE='NONE'
    file_name.gsub!(/[^ -~\t]/,' ')                   #ASCII �����ȊO���󔒂ɕϊ�
    file_name.gsub!(/[\\\/:\*\?\"<>\|]/,' ')          #�t�@�C�����Ɏg���Ȃ��������󔒂ɕϊ�
    $KCODE='s'
  else
    file_name.gsub!("\\","��") #�t�@�C�����Ɏg���Ȃ�������S�p�ɕϊ�
    file_name.gsub!("/","�^")  #�t�@�C�����Ɏg���Ȃ�������S�p�ɕϊ�
    file_name.gsub!(":","�F")  #�t�@�C�����Ɏg���Ȃ�������S�p�ɕϊ�
    file_name.gsub!("*","��")  #�t�@�C�����Ɏg���Ȃ�������S�p�ɕϊ�
    file_name.gsub!("?","�H")  #�t�@�C�����Ɏg���Ȃ�������S�p�ɕϊ�
    file_name.gsub!("\"","��") #�t�@�C�����Ɏg���Ȃ�������S�p�ɕϊ�
    file_name.gsub!("<","��")  #�t�@�C�����Ɏg���Ȃ�������S�p�ɕϊ�
    file_name.gsub!(">","��")  #�t�@�C�����Ɏg���Ȃ�������S�p�ɕϊ�
    file_name.gsub!("|","�b")  #�t�@�C�����Ɏg���Ȃ�������S�p�ɕϊ�
  end
  return file_name
end

def bsr_search(songHash)
  beatsaver_data = {}
  if songHash =~ /^[0-9A-F]{40}/i
    begin
      beatsaver_data = JSON.parse(`curl.exe --connect-timeout #{CURL_TIMEOUT} #{BEATSAVER_BYHASH_URL}#{songHash[0,40]}`)
      bsr = beatsaver_data['key']
    rescue
      bsr = 'err'
    end
  else
    bsr = 'nil'
  end
  return [bsr,beatsaver_data]
end

def ranked_check(main_self,song_hash,difficulty,mode)
  unless $scoresaber_ranked
    SCORESABAER_URL =~ /limit=(\d+)/
    limit = $1.to_i
    $scoresaber_ranked = {"songs" => []}
    page = 0
    main_self.show(0)
    begin
      begin
        page += 1
        url = SCORESABAER_URL.sub(/page=1/,"page=#{page}")
        temp = JSON.parse(`curl.exe --connect-timeout #{CURL_TIMEOUT * 4} #{url}`)
        $scoresaber_ranked["songs"] += temp["songs"]
        rank_map_count = $scoresaber_ranked["songs"].size
      end while rank_map_count >= limit * page
      puts "Rank map count = #{rank_map_count}"
    rescue
      $scoresaber_ranked = {}
      puts "ScoreSaber ERROR!"
    end
    main_self.show
  end
  if $scoresaber_ranked == {}
    return false
  else
    $scoresaber_ranked["songs"].each do |song|
      return 1 if song["id"] == song_hash && song["diff"] == "_#{difficulty.sub(/\+/,"Plus")}_#{mode}" && song["ranked"] == 1
    end
  end
  return 2
end

def open_url(url)
  begin
    #�O���v���O�����Ăяo���ŁA�����҂����Ȃ�����WSH��Run���g��
    $winshell.Run(%Q!"#{url}"!)
  rescue Exception => e
    messageBox("#{MAIN_WSH_ERR}\r\n#{e.inspect}", MAIN_WSH_ERR_TITLE, 16)
  end
end

#�v���C���X�g�쐬
def playlist_convert(select_list,name_output,image_file,description,title,author)
  bplist_data = {}
  songs_array = []
  select_list.each do |a|
    songHash, songName, levelAuthorName, songAuthorName, bsr = a
    song_data = {}
    if name_output
      if $ascii_mode
        song_data['songName'] = songName.strip
      else
        song_data['songName'] = utf8cv(songName.strip)
      end
    end
    song_data['key'] = bsr if bsr
    song_data['hash'] = songHash
    songs_array.push song_data
  end
  bplist_data['songs'] = songs_array
  if $ascii_mode
    bplist_data['playlistTitle'] = title
    bplist_data['playlistDescription'] = description
    bplist_data['playlistAuthor'] = author
  else
    bplist_data['playlistTitle'] = utf8cv(title)
    bplist_data['playlistDescription'] = utf8cv(description)
    bplist_data['playlistAuthor'] = utf8cv(author)
  end
  if File.exist?(image_file)
    image_data = File.open(image_file, "rb") {|f| f.read }
    image_base64 = Base64.encode64(image_data).split().join()
    if File.extname(image_file) =~ /\.png$/i
      type = 'png'
    else
      type = 'undefined'
    end
    bplist_data['image'] = "data:image/#{type};base64,#{image_base64}"
  else
    bplist_data['image'] = '1'
  end
  return bplist_data
end

#�_�C�A���O�̋N�����ʒu����
def dlg_move(dlg_self)
  m = $main_windowrect
  d = dlg_self.windowrect
  cx = m[0] + (m[2] / 2)
  cy = m[1] + (m[3] / 2)
  x = cx - (d[2] / 2)
  y = cy - (d[3] / 2)
  dlg_self.move(x, y, d[2], d[3])
end