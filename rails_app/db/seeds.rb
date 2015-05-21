# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
Dir.glob(Rails.root.join 'db', 'functions', '*.sql').each{|path|
  sql = File.open(path){|f| f.read }
  ActiveRecord::Base.connection.execute sql
}

if User.select("1").where(user_name: 'admin').first.blank?
  admin = User.new
  admin.user_name   = 'admin'
  admin.first_name  = 'admin'
  admin.last_name   = 'admin'
  admin.is_admin    = true
  admin.password    = 'admin*1234'
  admin.email       = 'wattaint@gmail.com'
  admin.save!
end
########################################################################################################################
def init_ref model, field, words
  words.each{|word|
    cond = {}
    cond[field] = word

    if model.select("1").where(cond).where(deleted_at: nil).first.blank?
      n = model.new 
      n[field] = word
      n.created_by = 'rake db:seed'
      n.updated_by = 'rake db:seed'
      n.save!
    end
  }
end
########################################################################################################################
# customer
init_ref RefCustomer, :cust_name, [
  'Katolec (Vietnam)', 'KSN', 'KTN', 'NBS', 'NC', 
  'NIC', 'NIDEC', 'NLC', 'NMB-C', 'NMB-Thai', 'NOBLE (Eletronic)', 
  'Noble Trading Bangkok', 'RHYTHM', 'SIIX (Bangkok)'
] 
########################################################################################################################
# customer
init_ref RefFreightTerm, :freight_term, [
  'C.I.F.HONGKONG', 'C.I.F.YANGON', 'C.I.F.DALIAN', 'C.I.F.SAVANNAKHET', 'C.I.F.TOKYO', 
  'F.O.B.BANGKOK', 'F.O.B.AYUTTHAYA', 'D.A.T.WUXI', 'C.I.F.HA-NOI', 'C.I.F.AYUTTHAYA', 'C.I.F.SHANGHAI', 
  'C.I.F.SENDAI', 'C.I.P.TOKYO', 'F.C.A.BANGKOK'
]
#######################################################################################################################
init_ref RefUnitPrice, :unit_name, [
  'THB', 'USD', 'JPY'
]
#######################################################################################################################
init_ref RefModel, :model_name, ['Q1410',
'Q1110',
'R1420',
'AD85',
'ADZ85',
'DSLR',
'CLNS',
'CLNS',
'COMN',
'FG',
'P700',
'P800',
'P900',
'P910',
'Q0065',
'Q0285',
'Q07065',
'Q1010',
'Q1020',
'Q1120',
'Q1140',
'Q1230',
'Q1310',
'Q2105',
'Q2125',
'Q220',
'Q220N',
'Q3035',
'Q310',
'Q3175',
'Q320',
'Q330',
'Q340',
'Q4085',
'Q430',
'Q5045',
'Q5135',
'Q5155',
'Q550',
'Q610',
'Q630',
'Q640',
'Q650',
'Q650_Ritz',
'Q7065',
'Q720',
'Q7345',
'Q740',
'Q740RD',
'Q740S',
'Q750',
'Q760',
'Q770',
'Q810',
'Q830',
'Q830RD',
'Q830S',
'Q8335',
'Q860',
'Q0870',
'Q910',
'Q920',
'Q930',
'Q970',
'Q970BLK',
'Q970BRO',
'Q970RD',
'R102',
'R119',
'R1270',
'R129',
'R130',
'R136',
'R140',
'R141',
'R146',
'R147',
'R153',
'R164',
'R306',
'R309',
'R313',
'R314',
'R321',
'R322',
'R324',
'R326',
'R327',
'R329',
'R331',
'R332',
'R332 & R340',
'R337',
'R339',
'R340',
'R341',
'R342',
'R343',
'R347',
'R349',
'R354',
'R355',
'R358',
'R524',
'R702',
'R703',
'R708',
'R709',
'R710',
'R713',
'R714',
'R715',
'R723',
'R724',
'TZ-SWM',
'V1060',
'V720',
'V730',
'V740',
'V810',
'V910',
'V920',
'R1330',
'R14110']