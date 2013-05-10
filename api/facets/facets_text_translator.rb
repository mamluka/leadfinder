class FacetsTextTranslator
  def initialize
    @translation = {
        language: {
            A1: 'Afrikaans',
            A2: 'Albanian',
            A3: 'Amharic',
            A4: 'Arabic',
            A5: 'Armenian',
            A6: 'Ashanti',
            A7: 'Azeri',
            B1: 'Bantu',
            B2: 'Basque',
            B3: 'Bengali',
            B4: 'Bulgarian',
            B5: 'Burmese',
            C1: 'Chinese',
            C2: 'Comorian',
            C3: 'Czech',
            D1: 'Danish',
            D2: 'Dutch',
            D3: 'Dzongha',
            E1: 'English',
            E2: 'Estonian',
            F1: 'Farsi',
            F2: 'Finnish',
            F3: 'French',
            G1: 'Georgian',
            G2: 'German',
            G3: 'Ga',
            G4: 'Greek',
            H1: 'Hausa',
            H2: 'Hebrew',
            H3: 'Hindi',
            H4: 'Hungarian',
            I1: 'Icelandic',
            I2: 'Indonesian',
            I3: 'Italian',
            J1: 'Japanese',
            K1: 'Kazakh',
            K2: 'Khmer',
            K3: 'Kirghiz',
            K4: 'Korean',
            L1: 'Laotian',
            L2: 'Latvian',
            L3: 'Lithuanian',
            M1: 'Macedonian',
            M2: 'Malagasy',
            M3: 'Malay',
            M4: 'Moldavian',
            M5: 'Mongolian',
            N1: 'Nepali',
            N2: 'Norwegian',
            O1: 'Oromo',
            P1: 'Pashto',
            P2: 'Polish',
            P3: 'Portuguese',
            R1: 'Romanian',
            R2: 'Russian',
            S1: 'Samoan',
            S3: 'Sinhalese',
            S4: 'Slovakian',
            S5: 'Slovenian',
            S6: 'Somali',
            S7: 'Sotho',
            S8: 'Spanish',
            S9: 'Swahili',
            SA: 'Swazi',
            SB: 'Swedish',
            T1: 'Tagalog',
            T2: 'Tajik',
            T3: 'Thai',
            T4: 'Tibetan',
            T5: 'Tongan',
            T6: 'Turkish',
            T7: 'Turkmeni',
            T8: 'Tswana',
            UX: 'Unknown',
            U1: 'Urdu',
            U2: 'Uzbeki',
            V1: 'Vietnamese',
            X1: 'Xhosa',
            Z1: 'Zulu',
        },
        education: {
            A: 'Completed High School',
            B: 'Completed College',
            C: 'Completed Graduate School',
            D: 'Attended Vocational/Technical'
        },
        occupation: {
            A: 'Professional / Technical',
            B: 'Administration / Managerial',
            C: 'Sales / Service',
            D: 'Clerical / White Collar',
            E: 'Craftsman / Blue Collar',
            F: 'Student',
            G: 'Homemaker',
            H: 'Retired',
            I: 'Farmer',
            J: 'Military',
            K: 'Religious',
            L: 'Self Employed',
            M: 'Self Employed - Professional / Technical',
            N: 'Self Employed - Administration / Managerial',
            O: 'Self Employed - Sales / Service',
            P: 'Self Employed - Clerical / White Collar',
            Q: 'Self Employed - Craftsman / Blue Collar',
            R: 'Self Employed - Student',
            S: 'Self Employed - Homemaker',
            T: 'Self Employed - Retired',
            U: 'Self Employed - Other',
            V: 'Educator',
            W: 'Financial Professional',
            X: 'Legal Professional',
            Y: 'Medical Professional',
            Z: 'Other'
        },
        occupation_detailed: {
            M698: 'Account Executive',
            W598: 'Accounting/Biller/Billing clerk',
            W597: 'Actor/Entertainer/Announcer',
            W596: 'Adjuster',
            W595: 'Administration/Management',
            W594: 'Advertising',
            W593: 'Agent',
            W592: 'Aide/Assistant',
            W591: 'Aide/Assistant/Executive',
            W590: 'Aide/Assistant/Office',
            W589: 'Aide/Assistant/School',
            W588: 'Aide/Assistant/Staff',
            W587: 'Aide/Assistant/Technical',
            A196: 'Air Force',
            C128: 'Air Traffic Control',
            W586: 'Analyst',
            L498: 'Animal Technician/Groomer',
            W585: 'Appraiser',
            L497: 'Apprentice',
            T998: 'Architect',
            A199: 'Armed Forces',
            A198: 'Army Credit Union Trades',
            W584: 'Artist',
            L496: 'Assembler',
            L495: 'Athlete/Professional',
            L494: 'Attendant',
            W583: 'Auctioneer',
            W582: 'Auditor',
            L493: 'Auto Mechanic',
            L492: 'Baker',
            W581: 'Banker',
            W580: 'Banker/Loan Office',
            W579: 'Banker/Loan Processor',
            L491: 'Barber/Hairstylist/Beautician',
            L490: 'Bartender',
            L489: 'Binder',
            L499: 'Blue Collar Worker',
            L488: 'Bodyman',
            W578: 'Bookkeeper',
            L487: 'Brakeman',
            L486: 'Brewer',
            W577: 'Broker',
            W576: 'Broker/Stock/Trader',
            L485: 'Butcher/Meat Cutter',
            W575: 'Buyer',
            L484: 'Carpenter/Furniture/Woodworking',
            W574: 'Cashier',
            W573: 'Caterer',
            E798: 'CEO/CFO/Chairman/Corp Officer',
            W572: 'Checker',
            L483: 'Chef/Butler',
            T997: 'Chemist',
            L482: 'Child Care/Day Care/Babysitter',
            H348: 'Chiropractor',
            C129: 'Civil Service',
            C127: 'Civil Service/Government',
            W571: 'Claims Examiner/Rep/Adjudicator',
            L481: 'Cleaner/Laundry',
            W570: 'Clerk',
            L480: 'Clerk/Deli',
            W569: 'Clerk/File',
            L479: 'Clerk/Produce',
            L478: 'Clerk/Stock',
            I149: 'Coach',
            A194: 'Coast Guard',
            W568: 'Collector',
            W567: 'Communications',
            E797: 'Comptroller',
            T899: 'Computer',
            T898: 'Computer Operator',
            T897: 'Computer Programmer',
            T896: 'Computer/Systems Analyst',
            L477: 'Conductor',
            W566: 'Conservation/Environment',
            L476: 'Construction',
            W565: 'Consultant/Advisor',
            L475: 'Cook',
            W564: 'Coordinator',
            C126: 'Corrections/Probation/Parole',
            L474: 'Cosmetologist',
            I148: 'Counselor',
            L473: 'Courier/Delivery/Messenger',
            C125: 'Court Reporter',
            L472: 'Crewman',
            T996: 'Curator',
            L471: 'Custodian',
            W563: 'Customer Service/Representative',
            L470: 'Cutter',
            S295: 'Data Entry/Key Punch',
            H347: 'Dental Assistant',
            H346: 'Dental Hygienist',
            H345: 'Dentist',
            W562: 'Designer',
            W561: 'Detective/Investigator',
            H344: 'Dietician',
            M697: 'Director/Art Director',
            M696: 'Director/Executive Director',
            W560: 'Dispatcher',
            L469: 'Dock Worker',
            W559: 'Draftsman',
            L468: 'Driver',
            L467: 'Driver/Bus Driver',
            L466: 'Driver/Truck Driver',
            M695: 'Editor',
            L465: 'Electrician',
            T995: 'Engineer',
            T994: 'Engineer/Aerospace',
            T993: 'Engineer/Chemical',
            T992: 'Engineer/Civil',
            T991: 'Engineer/Electrical/Electronic',
            T990: 'Engineer/Field',
            T989: 'Engineer/Industrial',
            T988: 'Engineer/Mechanical',
            W558: 'Estimator',
            E799: 'Executive/Upper Management',
            W557: 'Expeditor',
            L464: 'Fabricator',
            L463: 'Factory Workman',
            L462: 'Farmer/Dairyman',
            W556: 'Finance',
            L461: 'Finisher',
            C124: 'Firefighter',
            L460: 'Fisherman/Seaman',
            L459: 'Fitter',
            W555: 'Flight Attendant/Steward',
            W554: 'Florist',
            L458: 'Food Service',
            L457: 'Foreman/Crew leader',
            L456: 'Foreman/Shop Foreman',
            L455: 'Forestry',
            L454: 'Foundry Worker',
            L453: 'Furrier',
            L452: 'Gardener/Landscaper',
            T987: 'Geologist',
            L451: 'Glazier',
            W553: 'Graphic Designer/Commercial Artist',
            L450: 'Grinder',
            L449: 'Grocer',
            H343: 'Health Care',
            H349: 'Health Services',
            L448: 'Helper',
            T986: 'Home Economist',
            P249: 'Homemaker',
            W552: 'Hostess/Host/Usher',
            L447: 'Housekeeper/Maid',
            L446: 'Inspector',
            L445: 'Installer',
            I147: 'Instructor',
            W551: 'Insurance/Agent',
            W550: 'Insurance/Underwriter',
            W549: 'Interior Designer',
            L444: 'Ironworker',
            L443: 'Janitor',
            W548: 'Jeweler',
            L442: 'Journeyman',
            C123: 'Judge/Referee',
            L441: 'Laborer',
            I146: 'Lecturer',
            S298: 'Legal Secretary',
            T985: 'Legal/Attorney/Lawyer',
            S299: 'Legal/Paralegal/Assistant',
            T984: 'Librarian/Archivist',
            L440: 'Lineman',
            L439: 'Lithographer',
            L438: 'Loader',
            L437: 'Locksmith',
            L436: 'Machinist',
            C122: 'Mail Carrier/Postal',
            C121: 'Mail/Postmaster',
            L435: 'Maintenance',
            L434: 'Maintenance/Supervisor',
            M694: 'Manager',
            M693: 'Manager/Assistant Manager',
            M692: 'Manager/Branch Manager',
            M691: 'Manager/Credit Manager',
            M690: 'Manager/District Manager',
            M689: 'Manager/Division Manager',
            M687: 'Manager/Marketing Manager',
            M686: 'Manager/Office Manager',
            M685: 'Manager/Plant Manager',
            M684: 'Manager/Product Manager',
            M683: 'Manager/Project Manager',
            M682: 'Manager/Property Manager',
            M681: 'Manager/Regional Manager',
            M680: 'Manager/Sales Manager',
            M679: 'Manager/Store Manager',
            M678: 'Manager/Traffic Manager',
            M677: 'Manager/Warehouse Manager',
            M688: 'Manger/General Manager',
            A193: 'Marines',
            W547: 'Marketing',
            L433: 'Mason/Brick/Etc.',
            L432: 'Material Handler',
            L431: 'Mechanic',
            H342: 'Medical Assistant',
            T983: 'Medical Doctor/Physician',
            H341: 'Medical Secretary',
            H340: 'Medical Technician',
            H339: 'Medical/Paramedic',
            W546: 'Merchandiser',
            L430: 'Meter Reader',
            M699: 'Middle Management',
            L429: 'Mill worker',
            L428: 'Millwright',
            L427: 'Miner',
            W545: 'Model',
            L426: 'Mold Maker/Molder/Injection Mold',
            W544: 'Musician/Music/Dance',
            A195: 'National Guard',
            A197: 'Navy Credit Union Trades',
            H329: 'Nurse',
            H328: 'Nurse (Registered)',
            H327: 'Nurse/LPN',
            H338: 'Nurses Aide/Orderly',
            L425: 'Oil Industry/Driller',
            L424: 'Operator',
            L423: 'Operator/Boilermaker',
            L422: 'Operator/Crane Operator',
            L421: 'Operator/Forklift Operator',
            L420: 'Operator/Machine Operator',
            H337: 'Optician',
            H336: 'Optometrist',
            L419: 'Packer',
            L418: 'Painter',
            P246: 'Part Time',
            L417: 'Parts (Auto Etc.)',
            T982: 'Pastor',
            W543: 'Personnel/Recruiter/Interviewer',
            H335: 'Pharmacist/Pharmacy',
            W542: 'Photography',
            T981: 'Pilot',
            L416: 'Pipe fitter',
            M676: 'Planner',
            L415: 'Plumber',
            C120: 'Police/Trooper',
            L414: 'Polisher',
            E796: 'Politician/Legislator/Diplomat',
            L413: 'Porter',
            E795: 'President',
            L412: 'Press Operator',
            L411: 'Presser',
            M675: 'Principal/Dean/Educator',
            L410: 'Printer',
            L409: 'Production',
            T999: 'Professional',
            I145: 'Professor',
            H334: 'Psychologist',
            W541: 'Public Relations',
            W540: 'Publishing',
            W539: 'Purchasing',
            W538: 'Quality Control',
            W537: 'Real Estate/Realtor',
            W536: 'Receptionist',
            L408: 'Repairman',
            W535: 'Reporter',
            W534: 'Researcher',
            P248: 'Retired',
            P247: 'Retired/Pensioner',
            L407: 'Roofer',
            W533: 'Sales',
            W532: 'Sales Clerk/Counterman',
            L406: 'Sanitation/Exterminator',
            T980: 'Scientist',
            L405: 'Seamstress/Tailor/Handicraft',
            S297: 'Secretary',
            W531: 'Security',
            L404: 'Setup man',
            L403: 'Sheet Metal Worker/Steel Worker',
            L402: 'Shipping/Import/Export/Custom',
            H326: 'Social Worker/Case Worker',
            L401: 'Sorter',
            T979: 'Statistician/Actuary',
            P245: 'Student',
            M674: 'Superintendent',
            M673: 'Supervisor',
            W530: 'Surveyor',
            I144: 'Teacher',
            W529: 'Technician',
            H333: 'Technician/Lab',
            H332: 'Technician/X-ray',
            W528: 'Telemarketer/Telephone/Operator',
            W527: 'Teller/Bank Teller',
            W526: 'Tester',
            H331: 'Therapist',
            H330: 'Therapists/Physical',
            L400: 'Toolmaker',
            I143: 'Trainer',
            W525: 'Transcripter/Translator',
            L399: 'Transportation',
            W524: 'Travel Agent',
            E794: 'Treasurer',
            L398: 'Typesetter',
            S296: 'Typist',
            W523: 'Union Member/Rep.',
            L397: 'Upholstery',
            L396: 'Utility',
            T978: 'Veterinarian',
            E793: 'Vice President',
            P244: 'Volunteer',
            L395: 'Waiter/Waitress',
            W522: 'Ward Clerk',
            W521: 'Water Treatment',
            L394: 'Welder',
            W599: 'White Collar Worker',
            W520: 'Writer',
        },
        business_owner: {
            1 => 'Accountant',
            2 => 'Builder',
            3 => 'Contractor',
            4 => 'Dealer/Retailer/Storekeeper',
            5 => 'Distributor/Wholesaler',
            6 => 'Funeral Director',
            7 => 'Maker/Manufacturer',
            8 => 'Owner',
            9 => 'Partner',
            A => 'Self-Employed'
        },
        home_owner: {
            O: 'Home Owner',
            R: 'Renter',
        },
        dwelling_type: {
            M: 'Multiple Family Dwelling Unit',
            S: 'Single Family Dwelling Unit',
        },
        lender_code: {
            001 => 'AAMES HM LNS',
            002 => 'ABN AMRO MTG GRP INC',
            003 => 'ACADEMY MTG CORP',
            004 => 'ACCREDITED HM LENDERS',
            005 => 'ACCUBANC MTG',
            006 => 'AEGIS FNDG CORP',
            007 => 'AEGIS WHOLESALE CORP',
            008 => 'ALLIANCE MTG CO',
            009 => 'ALLIED HM MTG CAP CORP',
            010 => 'AMERICAN BROKERS CONDUIT',
            011 => 'AMERICAN HM FNDG',
            012 => 'AMERICAN HM MTG',
            013 => 'AMERICAN HM MTG ACCEPT INC',
            014 => 'AMERICAN HM MTG ACCEPTANCE IN',
            015 => 'AMERICAN MTG NETWORK INC',
            016 => 'AMERICAN MTG NTWK/FL',
            017 => 'AMERICAN MTG SVC CO',
            018 => 'AMERICAN RESIDENTIAL MTG',
            019 => 'AMERICAN SVGS BK',
            020 => 'AMERICAS WHOLESALE LENDER',
            021 => 'AMSOUTH BK',
            022 => 'AMTRUST BK',
            023 => 'ARBOR NATIONAL MTG INC',
            024 => 'ARCS MTG INC',
            025 => 'ARGENT MTG CO LLC',
            026 => 'ARLINGTON CAP MTG CORP',
            027 => 'ARVEST MTG CO',
            028 => 'ATLANTIC COAST MTG',
            029 => 'BANC ONE MTG CO',
            030 => 'BANCGROUP MTG CORP',
            031 => 'BANCO POPULAR NORTH AMERICA',
            032 => 'BANK OF AMERICA',
            033 => 'BANK OF AMERICA FSB',
            034 => 'BANK OF AMERICA NATL TR & SVG',
            035 => 'BANK OF HI',
            036 => 'BANK OF OK',
            037 => 'BANK ONE NA',
            038 => 'BANK UNITED',
            039 => 'BANK UNITED/TX FSB',
            040 => 'BANKUNITED FSB',
            041 => 'BEAZER MTG CORP',
            042 => 'BEAZER MTG CORP',
            043 => 'BF SAUL MTG CO',
            044 => 'BNC MTG INC',
            045 => 'BNY MTG CO LLC',
            046 => 'BOEING EMPS CU',
            047 => 'BRANCH BKNG & TR CO',
            048 => 'BROADVIEW MTG',
            049 => 'BROKERSOURCE',
            050 => 'C&F MTG CORP',
            051 => 'CALIFORNIA FEDERAL BK',
            052 => 'CAPITOL COMMERCE MTG',
            053 => 'CCO MTG CORP',
            054 => 'CENDANT MTG CORP',
            055 => 'CENTRAL PACIFIC MTG CO',
            056 => 'CENTURY 21 (R) MTG (SM)',
            057 => 'CENTURY 21 MTG CORP',
            058 => 'CH MTG CO I LTD',
            059 => 'CH MTG CO I LTD LP',
            060 => 'CHAPEL MTG',
            061 => 'CHARTER ONE BK',
            062 => 'CHARTER ONE BK FSB',
            063 => 'CHARTER ONE MTG CORP',
            064 => 'CHASE BK USA NA',
            065 => 'CHASE HM MTG',
            066 => 'CHASE MANHATTAN BK',
            067 => 'CHASE MANHATTAN MTG',
            068 => 'CHEMICAL BK',
            069 => 'CHEMICAL RESIDENTIAL MTG CORP',
            070 => 'CHERRY CREEK MTG',
            071 => 'CHEVY CHASE BK FSB',
            072 => 'CIT GRP/CONSUMER FIN INC',
            073 => 'CITIBANK FSB',
            074 => 'CITIBANK NA',
            075 => 'CITICORP MTG',
            076 => 'CITIMORTGAGE',
            077 => 'CLARION MTG CAP INC',
            078 => 'CMG MTG INC',
            079 => 'COLDWELL BANKER HM LNS',
            080 => 'COLDWELL BANKER MTG',
            081 => 'COLONIAL NATIONAL MTG',
            082 => 'COLONY MTG',
            083 => 'COLUMBIA NATIONAL INC',
            084 => 'COMMERCE BK',
            085 => 'COMMERCE SEC BK',
            086 => 'COMMONWEALTH UNITED MTG',
            087 => 'COMMUNITY MTG CORP',
            088 => 'COMPASS BK',
            089 => 'COMUNITY LENDING',
            090 => 'CONTINENTAL SVGS BK',
            091 => 'CORNERSTONE MTG CO',
            092 => 'COUNTRYWIDE BK',
            093 => 'COUNTRYWIDE BK FSB',
            094 => 'COUNTRYWIDE FNDG',
            095 => 'COUNTRYWIDE FUND',
            096 => 'COUNTRYWIDE HM LNS INC',
            097 => 'COUNTRYWIDE KB HM LNS',
            098 => 'CRESTAR MTG CORP',
            099 => 'CROSSLAND MTG CORP',
            100 => 'CTX MTG CO',
            101 => 'CTX MTG CO LLC',
            102 => 'DECISION ONE MTG CO LLC',
            103 => 'DEL WEBB HM FIN',
            104 => 'DHI MTG CO LTD',
            105 => 'DHI MTG CO LTD LP',
            106 => 'DIME SVGS BK/NY',
            107 => 'DIRECTORS MTG CO',
            108 => 'DIRECTORS MTG LN',
            109 => 'DITECH.COM',
            110 => 'DOWNEY S&L ASSN FA',
            111 => 'E TRADE MTG CORP',
            112 => 'EAGLE HM MTG INC',
            113 => 'EASTERN MTG SVCS INC',
            114 => 'E-LOAN INC',
            115 => 'ENCORE CREDIT CORP',
            116 => 'EQUIFIRST CORP',
            117 => 'ERA MTG',
            118 => 'EVERBANK',
            119 => 'FAIRWAY INDEPENDENT MTG CORP',
            120 => 'FAMILY LENDING SVCS INC',
            121 => 'FIELDSTONE MTG CO',
            122 => 'FIFTH THIRD BK',
            123 => 'FIFTH THIRD MTG CO',
            124 => 'FINANCE AMERICA LLC',
            125 => 'FIRST CITIZENS BK&TR CO',
            126 => 'FIRST FEDERAL BK',
            127 => 'FIRST FEDERAL S&L',
            128 => 'FIRST FRANKLIN',
            129 => 'FIRST FRANKLIN FINANCIAL',
            130 => 'FIRST FRANKLIN FINANCIAL CORP',
            131 => 'FIRST GUARANTY MTG',
            132 => 'FIRST HM MTG',
            133 => 'FIRST HORIZON HM LN',
            134 => 'FIRST HORIZON HM LN CORP',
            135 => 'FIRST MAGNUS FINANCIAL CORP',
            136 => 'FIRST MARINER BK',
            137 => 'FIRST MERIT MTG CORP',
            138 => 'FIRST MTG',
            139 => 'FIRST MTG CO LLC',
            140 => 'FIRST MTG CORP',
            141 => 'FIRST NATIONWIDE MTG CORP',
            142 => 'FIRST NATIONAL BK',
            143 => 'FIRST NATIONAL BK/AZ',
            144 => 'FIRST NATIONAL BK/AZ',
            145 => 'FIRST NLC FINANCIAL SVCS LLC',
            146 => 'FIRST OH MTG',
            147 => 'FIRST PLACE BK',
            148 => 'FIRST PREFERENCE MTG CORP',
            149 => 'FIRST SOUTH BK',
            150 => 'FIRST SVGS MTG CORP',
            151 => 'FIRST TN HM LNS',
            152 => 'FIRST UNION MTG CORP',
            153 => 'FIRST UNION NATIONAL BK',
            154 => 'FIRST UNION NATIONAL BK/FL',
            155 => 'FLAGSTAR BK FSB',
            156 => 'FLEET MTG CORP',
            157 => 'FLEET NATIONAL BK',
            158 => 'FLEET R/E FNDG CORP',
            159 => 'FNMC',
            160 => 'FRANKLIN AMERICAN MTG CO',
            161 => 'FREEDOM MTG',
            162 => 'FREEDOM MTG CORP',
            163 => 'FREMONT INVS & LN',
            164 => 'FULL SPECTRUM LENDING INC',
            165 => 'GATEWAY FNDG DIV MTG',
            166 => 'GATEWAY FNDG DIV MTG SVCS LP',
            167 => 'GEORGE MASON MTG LLC',
            168 => 'GERSHMAN INV CORP',
            169 => 'GMAC BK',
            170 => 'GMAC MTG',
            171 => 'GMAC MTG CORP/PA',
            172 => 'GMAC MTG CORP/PA',
            173 => 'GMAC MTG LLC',
            174 => 'GMAC MTG LLC',
            175 => 'GN MTG CORP',
            176 => 'GN MTG LLC',
            177 => 'GOLDEN EMPIRE MTG INC',
            178 => 'GOLF SVGS BK',
            179 => 'GREAT WSTRN BK',
            180 => 'GREAT WSTRN BK FSB',
            181 => 'GREAT WSTRN MTG',
            182 => 'GREEN POINT SVGS BK',
            183 => 'GREENPOINT MTG FNDG',
            184 => 'GUARANTEED RATE INC',
            185 => 'GUARANTY RESIDENTIAL LNDG INC',
            186 => 'GUARDIAN MTG',
            187 => 'GUILD MTG CO',
            188 => 'HABITAT FOR HUMANITY',
            189 => 'HARBOR FSB',
            190 => 'HARRIS TR SVGS BK',
            191 => 'HEADLANDS MTG INC',
            192 => 'HOME AMERICA MTG INC',
            193 => 'HOME LN CORP',
            194 => 'HOME SVGS/AMERICA',
            195 => 'HOME SVGS/AMERICA FSB',
            196 => 'HOME123 CORP',
            197 => 'HOMEAMERICAN MTG CORP',
            198 => 'HOMEBANC MTG',
            199 => 'HOMECOMINGS FINANCIAL LLC',
            200 => 'HOMECOMINGS FINANCIAL NETWORK INC',
            201 => 'HOMESIDE LENDING INC',
            202 => 'HOMESTEAD MTG INC',
            203 => 'HOMESTREET BK',
            204 => 'HSBC MTG CORP (USA)',
            205 => 'HUDSON CTY SVGS BK',
            206 => 'HUNTINGTON MTG',
            207 => 'HUNTINGTON NATIONAL BK',
            208 => 'ICM MTG',
            209 => 'IMCO RLTY SVC INC',
            210 => 'IMPAC LENDING GRP',
            211 => 'INDYMAC BK FSB',
            212 => 'ING BK FSB',
            213 => 'INLAND MTG CORP',
            214 => 'IRWIN MTG CORP',
            215 => 'IRWIN MTG CORP',
            216 => 'IVANHOE FINANCIAL',
            217 => 'JP MORGAN CHASE BK',
            218 => 'K HOVNANIAN AMERICAN MTG LLC',
            219 => 'K HOVNANIAN MTG',
            220 => 'KAUFMAN & BROAD MTG',
            221 => 'KB HM MTG',
            222 => 'KEYBANK NATIONAL',
            223 => 'LEHMAN BROTHERS BK FSB',
            224 => 'LENDER SELLER',
            225 => 'LENDER UNKNOWN',
            226 => 'LIBERTY MTG',
            227 => 'LOANCITY',
            228 => 'LOANCITY.COM',
            229 => 'LONG BCH MTG CO',
            230 => 'LONG ISLAND SVGS BK',
            231 => 'M&I MARSHALL & ILSLEY BK',
            232 => 'M&I MARSHALL & ISLEY BK',
            233 => 'M&T MTG CORP',
            234 => 'M/I FINANCIAL CORP',
            235 => 'MARGARETTEN & CO INC',
            236 => 'MARINA MTG',
            237 => 'MARKET STREET MTG CORP',
            238 => 'MARYLAND NATIONAL MTG CORP',
            239 => 'MATRIX FINANCIAL SVCS',
            240 => 'MCCUE MTG CO',
            241 => 'MEDALLION MTG CO',
            242 => 'MELLON MTG CO',
            243 => 'MERCANTILE BK',
            244 => 'MERIDIAS CAP',
            245 => 'MERITAGE MTG CORP',
            246 => 'MERITAGE MTG CORP',
            247 => 'MERRILL LYNCH CREDIT CORP',
            248 => 'MERS',
            249 => 'METROCITIES MTG LLC',
            250 => 'MIDAMERICA BK FSB',
            251 => 'MISCELLANEOUS FIN',
            252 => 'MISSION HILLS MTG',
            253 => 'MIT LENDING',
            254 => 'MNC MTG CORP',
            255 => 'MORTGAGE ACCESS',
            256 => 'MORTGAGE AMERICA',
            257 => 'MORTGAGE INV LNDG ASSOC INC',
            258 => 'MORTGAGE LENDERS NETWORK USA',
            259 => 'MORTGAGE MARKET',
            260 => 'MORTGAGE MASTER',
            261 => 'MORTGAGEIT INC',
            262 => 'MTG ELCTRN REGISTRATION SYSS',
            263 => 'NATIONAL CTY BK',
            264 => 'NATIONAL CTY MTG',
            265 => 'NATIONAL CTY MTG CO',
            266 => 'NATIONAL CTY MTG SVCS CO',
            267 => 'NATIONAL PACIFIC MTG',
            268 => 'NATIONSBANC MTG CORP',
            269 => 'NATIONSBANK',
            270 => 'NAVY FCU',
            271 => 'NE MOVES MTG CO',
            272 => 'NEW AMERICA FINANCIAL INC',
            273 => 'NEW CENTURY MTG CORP',
            274 => 'NEW FREEDOM MTG CORP',
            275 => 'NEW SOUTH FSB',
            276 => 'NO NEW MTG',
            277 => 'NORTH AMERICAN MTG CO',
            278 => 'NORTH AMERICAN SVGS BK FSB',
            279 => 'NORWEST MTG INC',
            280 => 'NORWEST MTG INC/CA',
            281 => 'NOVASTAR MTG INC',
            282 => 'NVR MTG FIN INC',
            283 => 'NVR MTG FIN INC',
            284 => 'OHIO SVGS BK',
            285 => 'OLD KENT MTG CO',
            286 => 'OPTEUM FINANCIAL SVCS LLC',
            287 => 'OPTION ONE MTG CORP',
            288 => 'OPTION ONE MTG CORP',
            289 => 'OWNIT MTG SOLUTIONS INC',
            290 => 'PACIFIC GUARANTEE MTG',
            291 => 'PACIFIC REPUBLIC MTG CORP',
            292 => 'PEOPLES BK',
            293 => 'PEOPLES CHOICE HM LN INC',
            294 => 'PEOPLES FIRST CMNTY BK',
            295 => 'PEOPLES MTG',
            296 => 'PHH MTG',
            297 => 'PHH MTG SVC CORP',
            298 => 'PHH MTG SVCS',
            299 => 'PHH US MTG CORP',
            300 => 'PINE ST MTG',
            301 => 'PINNACLE FINANCIAL',
            302 => 'PLAZA HM MTG INC',
            303 => 'PNC MTG',
            304 => 'PNC MTG CORP/AMERICA',
            305 => 'PREFERRED HM MTG CO',
            306 => 'PRIME LENDING INC',
            307 => 'PRINCIPAL RESIDENTIAL MTG INC',
            308 => 'PRISM MTG CO',
            309 => 'PRIVATE INDIVIDUAL',
            310 => 'PROSPERITY MTG CORP',
            311 => 'PROVIDENT FNDG ASSOCS LP',
            312 => 'PROVIDENT FNDG GRP',
            313 => 'PROVIDENT MTG CORP',
            314 => 'PROVIDENT SVGS BK FSB',
            315 => 'PRUDENTIAL HM MTG',
            316 => 'PULASKI BK',
            317 => 'PULASKI MTG',
            318 => 'PULTE MTG CORP',
            319 => 'PULTE MTG LLC',
            320 => 'PURCHASE MONEY MTG',
            321 => 'QUICKEN LNS',
            322 => 'RBC CENTURA BK',
            323 => 'RBC MTG CO',
            324 => 'RBMG INC',
            325 => 'REALTY MTG CORP',
            326 => 'REGIONS BK',
            327 => 'REGIONS MTG',
            328 => 'REGIONS MTG INC',
            329 => 'REPUBLIC BK',
            330 => 'REPUBLIC CONSUMER LENDING GRP',
            331 => 'REPUBLIC MTG CO',
            332 => 'RESIDENTIAL MTG CAP',
            333 => 'RESMAE MTG CORP',
            334 => 'RESOURCE BK',
            335 => 'ROCKY MOUNTAIN MTG CO',
            336 => 'RYLAND MTG CO',
            337 => 'SAFRABANK',
            338 => 'SCME MTG BANKERS INC',
            339 => 'SEARS MTG CORP',
            340 => 'SEBRING CAP PTRS LP',
            341 => 'SECURED BANKERS MTG CO',
            342 => 'SECURITY NATIONAL MTG CO',
            343 => 'SELLER',
            344 => 'SHEA MTG',
            345 => 'SHELTER MTG CO LLC',
            346 => 'SIB MTG CORP',
            347 => 'SIERRA PACIFIC MTG CO',
            348 => 'SILVER ST MTG',
            349 => 'SIRVA MTG INC',
            350 => 'SKY BK',
            351 => 'SOURCE ONE MTG SVCS CORP',
            352 => 'SOUTHSTAR FNDG LLC',
            353 => 'SOUTHTRUST MTG',
            354 => 'SOVEREIGN BK',
            355 => 'SOVEREIGN BK',
            356 => 'SOVEREIGN BK FSB',
            357 => 'STANDARD FEDERAL BK',
            358 => 'STANDARD FSB',
            359 => 'STATE EMP CU',
            360 => 'STATE EMPS FCU',
            361 => 'STERLING CAP MTG CO',
            362 => 'SUBURBAN MTG INC',
            363 => 'SUMMIT BK',
            364 => 'SUMMIT MTG',
            365 => 'SUN AMERICA MTG CORP',
            366 => 'SUNBELT NATIONAL MTG',
            367 => 'SUNCOAST SCHOOLS FCU',
            368 => 'SUNSHINE MTG',
            369 => 'SUNTRUST BK',
            370 => 'SUNTRUST BK/GA',
            371 => 'SUNTRUST MTG INC',
            372 => 'TAYLOR BEAN & WHITAKER MTG',
            373 => 'TAYLOR, BEAN & WHITAKER MTG',
            374 => 'TEMPLE INLAND MTG CORP',
            375 => 'THIRD FED S&L ASSN CLEVE',
            376 => 'TRANSAMERICA',
            377 => 'TRANSAMERICA R/E TAX SVC',
            378 => 'TRAVELERS MTG SVC INC',
            379 => 'TRIDENT MTG',
            380 => 'TRIDENT MTG CO LP',
            381 => 'UNION BK/CA NA',
            382 => 'UNION FEDERAL BK/INDIANAPOLIS',
            383 => 'UNION FSB',
            384 => 'UNION FSB/INDIANAPOLIS',
            385 => 'UNION NATIONAL MTG CO',
            386 => 'UNION PLANTERS BK',
            387 => 'UNION PLANTERS BK',
            388 => 'UNION SVGS BK',
            389 => 'UNIVERSAL AMERICAN MTG CO',
            390 => 'UNIVERSAL AMERICAN MTG CO LLC',
            391 => 'UNIVERSAL AMERICAN MTG CO/CA',
            392 => 'UNIVERSAL LENDING',
            393 => 'UNIVERSAL MTG',
            394 => 'US BK NATIONAL ASSN',
            395 => 'US HM MTG',
            396 => 'USAA FSB',
            397 => 'VETERANS ADMN',
            398 => 'VIRGINIA HSNG & DEV AUTH',
            399 => 'WACHOVIA BK NA',
            400 => 'WACHOVIA MTG',
            401 => 'WACHOVIA MTG CO',
            402 => 'WASHINGTON MUTUAL',
            403 => 'WASHINGTON MUTUAL BK',
            404 => 'WASHINGTON MUTUAL BK FA',
            405 => 'WASHINGTON MUTUAL SVGS BK',
            406 => 'WEBSTER BK',
            407 => 'WEICHERT FINANCIAL SVCS',
            408 => 'WELLS FARGO BK',
            409 => 'WELLS FARGO BK NA',
            410 => 'WELLS FARGO HM MTG INC',
            411 => 'WESTAMERICA MTG CO',
            412 => 'WESTERN SUNRISE',
            413 => 'WEYERHAEUSER MTG CO',
            414 => 'WILMINGTON FIN INC',
            415 => 'WMC MTG CORP',
            416 => 'WORLD S&L',
            417 => 'WORLD SLA',
            418 => 'WORLD SVGS BK',
            419 => 'WORLD SVGS BK FSB',
            420 => 'WR STARKEY MTG LLP',
        }

    }
  end

  def translate(key, value)
    value = @translation[key.to_sym][value.capitalize.to_sym] if @translation.has_key?(key.to_sym)
    value
  end
end