require_relative 'api/buy/create-csv-for-customer'

CreateCsvForCustomer.perform 'david.mazvovsky@gmail.com', 100000, {"has_telephone_number" => "true", "state" => "al,ak,az,ar,ca,co,ct,de,dc,fl,ga,hi,id,il,in,ia,ks,ky,la,me,mt,ne,nv,nh,nj,nm,ny,nc,nd,oh,ok,or,md,ma,mi,mn,ms,mo,pa,ri,sc,sd,tn,tx,ut,vt,va,wa,wv,wi,wy"}, {'order_id' => 'david', 'name' => 'coolio'}