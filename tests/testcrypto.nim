## Nim-Libp2p
## Copyright (c) 2018 Status Research & Development GmbH
## Licensed under either of
##  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE))
##  * MIT license ([LICENSE-MIT](LICENSE-MIT))
## at your option.
## This file may not be copied, modified, or distributed except according to
## those terms.

## Test vectors was made using Go implementation
## https://github.com/libp2p/go-libp2p-crypto/blob/master/key.go
import unittest
import nimcrypto/[utils, sysrand]
import ../libp2p/crypto/[crypto, chacha20poly1305, curve25519]

when defined(nimHasUsed): {.used.}

const
  PrivateKeys = [
    """080012BE023082013A020100024100AD8A7D5B0EB7C852C1464E4567651F412C
       692534E1600FDC5BDA9EDBFA9927AF0FFA7C52599BE62999E085C345D21C8D43
       627CCC0E16D695C770E26D220AE709020301000102403B58BCFDC2CEBEC6EE29
       A8E2BB352DB71004F5205C62898A062F815C211AF722AADD1087C68E24015417
       E36632EEA2D2B1A20FF3D283A4C3881C724B3919FCF1022100D4BD1D7D15B328
       4EFBBB5B2C6A11CFB7BCD9000C1010D69C808F370DFA751D47022100D0D4CB1B
       BAB9F8C11376744F0D96D6E4BC2B12F4DF768AC9EEA79DAB24C8C12F02210089
       A3FA0A4E19E64083FA8A58C81FD2070CF651637C9988612584839855ADA44D02
       20137DD91B5479693B743A992E8BC1297B9E08933361EC2996217D699D00C8F0
       2702201A8D0497E8962E0AF5B15CA03085070F735B39876C54BA8908EDC87C42
       D9DADC""",
    """080012E0043082025C02010002818100B91DCD5578C2FA3EA7D1DF62F59DEEDA
       834ECE568844554163E1803CDF4C2988BE182B8F957D3405BC745A33DA1E714A
       BA13C316683767735ED72AE8B35648FD6E33A49D696FADB6499C63A09204F0BF
       77B44D3917DC746FB7B52040725746A3140E96E8682A02A4767C280DEFBE58C6
       ACB6DD1EE63F3F589F4C7941B27957F70203010001028180364CDFA66ABE06D9
       CA306DEE814DCA7A9E79C75CEAABE0B645AE2807B3188C36684C7EBAA7870A73
       844C3D0968B9F5518E33ADCE2CD3D3ACABED41D0F08A26EE705E4277AF0D5816
       491C626F6D2D5396A741B83D0730401B061A8C2DE19E18B07CE8798F387D4C79
       78C92DA6F4080A45F93D0ADE50CF7E139DB7288EBA72D341024100DE9B394C60
       6C396B65756CE4A2E3D77F66C3AFBDA0C09C3CD87EB60A35018BDA7D82FF119F
       F6EBAAEC868E8ED1AD215C9EBF4073F26A1B187CDAFC862540B1C3024100D4E2
       D92E126D92B6795EBD7991A2D8A35147FAB73CFA4BBE74644CE8D1AEDE10A2FF
       33CEDF0B4961A89B1121C58D233309589BFBDE72D374ECB6A6859B0CC9BD0241
       008B0ABB9C6831D11FB2CCC8CA7AB003BF9109B3B0A7430793BDCA4F9C4A857F
       BC665F3740E400D02CFFF5FFFF571A63D73D54CA4661E942A965FB4675E7B8E4
       0F02404A175D90DC57085DBBA60E79B6072030CF04272D08EAEFDBAC349053E3
       4E61F916518D9D6D21477BD6AB896DE08C7B78B2C3051EC6CFDDEA6ECC2EEE87
       050F5D02407BC18B68F253353D7DB89AA85A7CEC4069DAEB894828F83931ADC4
       9A3255DFD0C9AAF9D09EBFAE831588A360EB0EEB89E45C9D136DCEEC8EAEBD3E
       65FBA9EE01""",
    """080012A809308204A40201000282010100C8B014EC01E135D635F7E246BA7D42
       3E2B36F45B052F0B644DA6B1B6DD964696F279BB9BB5F5C41EE3204F74EF70C2
       28C8CDD97E4F19094274EB01C292EC25055CB3CECD1A41E8919A0C111602B1B8
       5B4E43DBB2F4898C52738465F35E3085586CF01E407BE6CB5F0C08D0AD6D6FE0
       2A43C932E124E9C8498E67BA323CC84A275ACCC20D586C04DAF54FE98018FF15
       62E80514735A3237AA3C1DD2B4281FCAD3BD94952F0397A3F15B06269107C147
       C15645DCB507C566E66BF24E2745A05E4D31F364C2C50C0F5C9A6889378051BF
       05669EA905C2370548D6EF2CF66A4A5DC23F10B7614BC43CF0BFCC8711B6FF9F
       645FC2E5713ED1CB5975392B8C8652026902030100010282010018F9B0E0DE2B
       04E42FBB35B1CFAB9EFED5A9F5270EB2181CD77D1348CAB2D4FE1C17023E129B
       0F5938B2E0B090CBDB9DEFBF8E7DA5A25C00A54449E7C919125264830C0D8263
       096A755D6312F62ADFE29D0EDCDC9C8A31A8612FECF0289CA93BA3F30E10C05A
       AC9C9B86CD5187F91050B236EBDA1119F70F1065E04A383E44DC008A143630AD
       B59064AB3D810C391B59BAEB8E7C29C38A6AD6B10EBAA456DCACFA00DB06CA61
       D630846EAF4B1A0292A695CBE5001BA8A2E419881263576358295E8B7A61E0A2
       7EFCA0EC37810873792B0F80D2DD877DCE383A704DE13BC0E8EF6D1CF4C71DE7
       306F6A0C3741DDCD81CF090746DD217925D5BEAF30B7D174B83102818100E35A
       50E392EF35CFFF9D24E0A71561E16E7CE99D13C3D9630305D74038F8F646D5CF
       440FEC38DFB145BAB25FA875C6B0B93DEF43CEDA51C52FF97BB02039913CD5BB
       36DB0D0B4DEAF0AF3A11D1DDD5991F18F6DDBEF4708B8B00DC6F99CC930E93D8
       84BF118D204E9A83C7B2163252731813A67A4043459D943549D8AFAED7EF0281
       8100E1F9A33FF755B1187302AD22B7C70FF2C6D4D5D8E765D337BECF3E417DDB
       57818588240F3A40FE2E6C73E3E0BA244FAFCC8988E010577AAD967D48203563
       4CBA45B8166269E5E64214EB23CAE8B1619F3B7910FFE343E88B4E6CDC57CE8A
       736ECD5B8B455C4B004D7222298663EDD4A59BDB718CA436A86BC2BA53BC0E7D
       B32702818100A5CFB7D0D1D7DE624D659980B2BAF8810628D9E47286D2E3D04F
       91364896E25EB50F0DEFA2F3B3C94136B162ECA4C0FD208CD8149727489DCCA8
       629A085693E34F69D3CF1C8B530F76EC0528FBEB931DB2BD6D463A3F6259934E
       54769C2FC44CCC6D0C1BA1BC5084A3525AF13A190762E37B695E1DC2326283B5
       FD9EA83A974702818100C493B88AE5AB5AD2AD0210011AA40560A9CCEE76B0DD
       687F9EF283F2CEFC67441A18535E17CC0011FC705834DF58C5256625E2B72020
       296D2673B7B1A51FCBD862DC0044FE606B0CE34BA6285682302D27BC6AA85F58
       6CCBFA9E4293F3ED86FB4593B434D353BF609FBFCE25C57A5838F4BB522D0991
       2EB40782B562EBAC37930281802E343D25B84AF8CAB1A298179FDE5F94D2EFF6
       1E51EF4784E5BBE4DC230F17B884B0074CA4603416F72C10D9137D79E28967C4
       8C0E4AEA1453952818FF9AD2FACCED7CE3A037D8545C151F57D35DED691CA53F
       8A5336590F7B080805A46701B01C9F9919E3890CA1A0373D909373638B57FD0C
       87627491C41F1BF1E9643DE7B4""",
    """080012AD12308209290201000282020100E35735127777C52E66252B014E9650
       01F3A515317B90DDAC8671F4F820AE67308DE2AA4162E99522CD6DA7EB9D7DB6
       06489FEB77341A8FA058FAC832EE6EE5E978D512FF79461FC419A23B27C39C81
       BB635228B0DA5CFAE87080AC1AAE4619BF4576771E6E24A04D98D55ADA5CBA55
       8EBE06ED14790D71438AFDC1FB9B4E2E623F221F8509A8CFE37265728EFBFAA6
       0C76E6FBC4A473511CE6EE8A72C1CE1E5D67AB9FC4FA6FE797B854DFE7064C23
       5ECB1379DB4B1E085F0042E19831D80CBE160A46C5154148A8D20E15C29F12AE
       208022EF094C5AC565153268DE8318CAFC82D2D71839EA136756FD4EBC3951F2
       60EE5DA51A63D9AC7B80B7968D769CC82DCE2494BAFE9505C124E947E0E8D3F4
       A6B207EE195B3FFBFED028DCE59DB5CD60B1C6C316B4A712DAC2E8BF46E00611
       6685BB77D56E00B2A63B74CFA5C7CAD003BD2DA9F865239DAB45FE52DAB9C792
       8A705F3A0A3DCEC0B45A73DCE0A63DA1E24417ECD9C4B51342600CD2963BBA4F
       A3DF170666B9804E1BCC9E7CF171571CB336F383B5A0FA375F7A7F72CC4F4460
       B8255F4F38556C360D712910B34A8ACE1C270175DFF5CECC7A34681835915BCE
       5FD4CA52D0F5A57685E28F5DCA1CA5A4410FDEAF516FC4F8226BCE2CFDBA9F83
       0DD9A0903A18E009BBE818D52D11AD85974021CE0CC908DEC21FD6163EC7FD55
       8150506FAE4FE6393EA3CC061EC9749DFD020301000102820200535C63E28C9A
       075C9729E3D60BDA0426630FD2709D8DA62B1FF5634D24B6AEB1D8251826F7BD
       0CE98108477D96F744AA9330C8A7A21C6733F5CCA7623D99BE8658BF50C30AD6
       12C9D6586D768C3CB4396116FC42B51F4905B85306489644B02639B351C47FC0
       C06313BA9020E7C58F9FD2C03968BB66997499DFA8A4B8F2F701218342A986BC
       36D680D90023BBF3D1B55A5822539DB58735A0DC313A19249A6FC796DFF3DB9C
       F2FFE8207F257862ACC9928F66AC69A3EE8FDF49A6ED26C1C11266848824B641
       85021A5BFDD0AA81B005CCD6826E1768655F466180A0AED3858307F985D3A550
       D6A29AFC3145C582EDEC6B1B3D722AD0E37539E297BAF19655B3FD0DCBBF06DF
       65135B59D6FD56F2587523B231C7736A39D1C73967E56EF9E1D093DE6136F74A
       CFABE1B0917F0C67724EA16FC7BD0CF57FF5AED3941AE5DA068A48B3F5726A56
       223DAF96A24F0D4D22E2CE81B189D0A75A52ECFA50AEE24149E8285E2FD0892E
       0D028EE5F39CEF0C070418C3C8CEAE1243481417F2277FC9207E8F78841653AF
       674B1C37A6E9CBF4D9EAB1DB9B43D19AA1F4E24F7A6416A4EE6DB565CDD05616
       A33EF1A61D74DF07506ACAE38DE6820F384560D39A53DD35302CEC5CDF0A6E42
       239EC3344EC5088C3E4787480F876223BBFCF70E48F39A37C4B43B33000F1D7B
       38128484865BC4E9614C3F8AB7FAB0829574ECFB30AAE5E954810282010100F9
       E86D7571EF36C6A6735EEDEE2AA87FA7A6D269B0EC79D6A4053BB7327ACBBE00
       8C5C713A056FCEF6777A5A3BC0BE7DB5B94032425394EF579F9847041765E3A0
       9E9DBD942C8C09BB8EBCB8F5E941055F75BCD2DB1337A93FE2D66B2D4F3F6741
       FAC20024402A067BD69892D830B8069D93AD3C47A46E12C78D6BA6292F3D3270
       2F72DC29DF1FDA9BCE4467D13D0A7BA4A69E65B1205F443CB015533788B62919
       EEA289BA5BAC4B943DA27B611FAAE83119CD5F877763475109ACECC97018BBC4
       973E34A83C09DD43EF6E4FBECC79BF8B5A9BDABEF78E139FFD5C549848B0B593
       377F105F5A4B2B44FCACC4745C56B54ABAD14DF31ABF738861F032D48DDE5D02
       82010100E8E1F25C4EDDF32B479E092C19C824DC02AF331570EE89A557F69936
       F40567377C1CFA0C077716EE8289D7F0467FA6CF96D483B62AFFCE075A8911EE
       47E77B56550F2874BA4FA9B6BDEB00606DFE4BE54A2257DCA1AB0B7C394973B3
       CAE48F9CB352452A6DDC1A8FA28AB85372F3E028C4CA44EE54EA61716F829FF9
       6FABDEC82EE86B1213C5355778F0262F5E1DC5F292F4BD663D3C37438A4469BB
       BDFCB3D0E0DE81C16154EBD1204F1D8AED4CFC97FFEB3066780EE143E78E2886
       0FB637A62F3B6E85428C6FD4F357017AF9647E33E16D1DDF17FF524E53FB8E4D
       3FE2B24D5DE0FEC1F9D2A6EA9CC63A3AA406584651A2CA6EB7A68AE00E8332C2
       185F842102820100367ACBF9F17793BA64A8FC05E488DA28D2149504437499EF
       07DCB832ECC746494A774EE3C42151498E0367E1E9EACFDC39D483C131226572
       73E8AFDAB372A25CA8344BF0FB2F66EBEC3E66B7EFAC04E7B5F2C5D235BE0FC1
       4ED315A951BC57F71BB41DBCC82A50BF0F1A2E32BCFC89F1AF42755E91C3AFD7
       5A3763435AF11867397BAE8F7E754CCD6C6FE00BBDDA8FC17A987429791EB485
       FCB0EA4534F311BB0E132ECDD5998C8B016B1A53C94D8D058746B7B5DEA3513A
       47D953205F9D9756BFB9B4EEE7CA06E07CA1E2AB71CDC3B0D521509EB448E569
       33D498DF3C3F847E60F49537AD81D2A74127D0461793D5B739EE5618A729AA98
       F61F5BACC917906502820101008F88DB810B56FF0E78D8ADDC91936B2C73371A
       AC276BCE48AB7BA1195EB389D787D6B04303C2E1CE6584A22444BF5EC7E9B5D7
       EC4A7A59B8EC93390AFD246E3F5AB3BA029FE683BACF396D8501A64F8EE5EF5E
       E9EC76E8E04ACABBD65FC219C5C23C7DC6D5E96831894428B1BE5313A0ED11A2
       04A72FC29950DA58D13B83DA0ED5E288439F0DD87FAE598D9F7A49AD7C8218F8
       37709C918F3E44464AE1A1440F04D9FF6D7A19063361CF816CE42FA42BE71F45
       3892DCD0F8B25A4B1DBDC7586B4407446A3C0724D2429D289B6BE50567E29407
       6A3E772E7A7A86BC415E93D1C39F8E1256EA2C6C9683C42595890D24114B35A3
       C133CE212051B1897259E55D210282010100999A507C3D551ECC5F68A63C80E5
       DC15177996E55203CDA99B69C1C6B4E2D7DE52660412BFD7CE9AC7C7427533A3
       A442DCA58CB14F7B776D3D9A681FC7D3762A789E4BFBC7D854704CFE1726154C
       DB9F1DC399AF2A687AFB2FCBD110EBD5A00AE8CA70DA5C94670AF149B909BC91
       829848B4479470D843E800D366F735F7BCE5F209775156FB57F6B77316CD54F2
       558938D43D500160A280F299906C8119BF67E6B080522EB7BF074E3E20141EA3
       4F4DAABB32A15D3693E301ED3F0E35F2F663EC3F3F93DD63063ECFB12FD29CCE
       F01A15B0BE6BA9BB352F11FF7DC08DB863BE69A77E4F3644EA12F949A3167FC8
       2E67516B0572EC62AB9F05775636808B9E3C""",
    """08031279307702010104202D19BABF4420E2F25F075A71DA9DA86E29596C6013
       B8FD50D5999F98DF636226A00A06082A8648CE3D030107A14403420004AA407C
       C163A2BFF807DAE1BB58A67A3C1A3C80CF83C31C9736607407137511F06812B6
       F497BA747F5CA6CB69E21ADA2F291A6040D2D58BD254E1ECCB13B72999""",
    """08011240B9EA7F0357B5C1247E4FCB5AD09C46818ECB07318CA84711875F4C6C
       E6B946186A4EB44E0D714B2A2D48263D75CF52D30BEF9D9AE2A9FEB7DAF1775F
       E731065A"""
  ]

  PublicKeys = [
    """0800125E305C300D06092A864886F70D0101010500034B003048024100AD8A7D
       5B0EB7C852C1464E4567651F412C692534E1600FDC5BDA9EDBFA9927AF0FFA7C
       52599BE62999E085C345D21C8D43627CCC0E16D695C770E26D220AE709020301
       0001""",
    """080012A20130819F300D06092A864886F70D010101050003818D003081890281
       8100B91DCD5578C2FA3EA7D1DF62F59DEEDA834ECE568844554163E1803CDF4C
       2988BE182B8F957D3405BC745A33DA1E714ABA13C316683767735ED72AE8B356
       48FD6E33A49D696FADB6499C63A09204F0BF77B44D3917DC746FB7B520407257
       46A3140E96E8682A02A4767C280DEFBE58C6ACB6DD1EE63F3F589F4C7941B279
       57F70203010001""",
    """080012A60230820122300D06092A864886F70D01010105000382010F00308201
       0A0282010100C8B014EC01E135D635F7E246BA7D423E2B36F45B052F0B644DA6
       B1B6DD964696F279BB9BB5F5C41EE3204F74EF70C228C8CDD97E4F19094274EB
       01C292EC25055CB3CECD1A41E8919A0C111602B1B85B4E43DBB2F4898C527384
       65F35E3085586CF01E407BE6CB5F0C08D0AD6D6FE02A43C932E124E9C8498E67
       BA323CC84A275ACCC20D586C04DAF54FE98018FF1562E80514735A3237AA3C1D
       D2B4281FCAD3BD94952F0397A3F15B06269107C147C15645DCB507C566E66BF2
       4E2745A05E4D31F364C2C50C0F5C9A6889378051BF05669EA905C2370548D6EF
       2CF66A4A5DC23F10B7614BC43CF0BFCC8711B6FF9F645FC2E5713ED1CB597539
       2B8C865202690203010001""",
    """080012A60430820222300D06092A864886F70D01010105000382020F00308202
       0A0282020100E35735127777C52E66252B014E965001F3A515317B90DDAC8671
       F4F820AE67308DE2AA4162E99522CD6DA7EB9D7DB606489FEB77341A8FA058FA
       C832EE6EE5E978D512FF79461FC419A23B27C39C81BB635228B0DA5CFAE87080
       AC1AAE4619BF4576771E6E24A04D98D55ADA5CBA558EBE06ED14790D71438AFD
       C1FB9B4E2E623F221F8509A8CFE37265728EFBFAA60C76E6FBC4A473511CE6EE
       8A72C1CE1E5D67AB9FC4FA6FE797B854DFE7064C235ECB1379DB4B1E085F0042
       E19831D80CBE160A46C5154148A8D20E15C29F12AE208022EF094C5AC5651532
       68DE8318CAFC82D2D71839EA136756FD4EBC3951F260EE5DA51A63D9AC7B80B7
       968D769CC82DCE2494BAFE9505C124E947E0E8D3F4A6B207EE195B3FFBFED028
       DCE59DB5CD60B1C6C316B4A712DAC2E8BF46E006116685BB77D56E00B2A63B74
       CFA5C7CAD003BD2DA9F865239DAB45FE52DAB9C7928A705F3A0A3DCEC0B45A73
       DCE0A63DA1E24417ECD9C4B51342600CD2963BBA4FA3DF170666B9804E1BCC9E
       7CF171571CB336F383B5A0FA375F7A7F72CC4F4460B8255F4F38556C360D7129
       10B34A8ACE1C270175DFF5CECC7A34681835915BCE5FD4CA52D0F5A57685E28F
       5DCA1CA5A4410FDEAF516FC4F8226BCE2CFDBA9F830DD9A0903A18E009BBE818
       D52D11AD85974021CE0CC908DEC21FD6163EC7FD558150506FAE4FE6393EA3CC
       061EC9749DFD0203010001""",
    """0803125B3059301306072A8648CE3D020106082A8648CE3D03010703420004AA
       407CC163A2BFF807DAE1BB58A67A3C1A3C80CF83C31C9736607407137511F068
       12B6F497BA747F5CA6CB69E21ADA2F291A6040D2D58BD254E1ECCB13B72999""",
    """080112206A4EB44E0D714B2A2D48263D75CF52D30BEF9D9AE2A9FEB7DAF1775F
       E731065A"""
  ]

  # Key expanding test vectors obtained from Go implementation
  # https://github.com/libp2p/go-libp2p-crypto/blob/master/key.go

  Secrets = [
    # AES-128 SHA-256
    "4F13360145891C202B74FDCA838A85A37CBAEBF5E0774CC344BD6DABA9C4C86A",
    """4ED31DA5EEA36277CA9E1C198F3EBB89AE4A6B18B76E48CAE8AEC23A7D0D4E8F
       700D6696AB01365278E5C45C2B4B1807""",
    """01D4FBB5104F9B8DEDA95B447C1401A35F995B6BEFE20DBEFF9F7A13B7DA2831
       FB5A7EA194C4CE1ECE340B993C4C2C53FE641227DB7428B62BF4083686F6FF8F
       BE8C""",
    # Edge case (where Go implementation returns 65 bytes of secret)
    # Nim implementation has leading `00`.
    """00691BB84462F460D603B3F5FA0031D8DE195234C65B8890CBB6F84456E9718D
       4572749FC6040D0602698EEE6CCF6FB83101A26925D1A3AB40FB45BF98EAF06A
       2693""",
    # AES-256 SHA-512
    "1F29EC3E0A07994D2ACCEA23A2F570DA9C7A7E39D5026FE6340C1E551E1ADAAF",
    """85C20386C1EA1575DD8D111111DBC8B43CA630BEE4BB9AD91658719FF307C0BE
       0065935B8B849BE80E0D08A3D39098C3""",
    """01779213E2993A77F1E1BB3B4DB77B5900B53A3A31CDE95D352C695643879824
       C8EE6501DC8679F5735869251256830A31357B34FF463B9292C02CD22CD30351
       C44F""",
    # Edge case (where Go implementation returns 65 bytes of secret)
    # Nim implementation has leading `00`.
    """001CC33294544D898781010258C2FB81F02429D2DD54D0B59B8CD2335F57498F
       D4E444BEC94DA7BE2BAF3E3796AFA8388F626AEB3178355991985EE5FFC9D1AA
       CAD9""",
    # AES-256 SHA-1
    "85076756644AAC06A47B29E25CB39B3E0C717152EE587F50C5A10281DB7F2FA5",
    """256D46C5E5449AA7B9BE985646D5F32E455BB4B7AAF3566507A023B72801A7BC
       5066647E82DE2BC37FE22AB0DE440F77""",
    """01FF82C71215CFFD7A42A5CED03BD2256D4A5B6850472A5C5CA90665D510F038
       A21F3A6EA0BB0A64113960C54DDAFC5E7A5F018E4413D7CC93C736A8D30579ED
       5A2B""",
    # Edge case (where Go implementation returns 65 bytes of secret)
    # Nim implementation has leading `00`.
    """00360D9410E58534AC6A89CA5AC17E9455F619DCA71A6C2FB6F3156AE58DDB91
       6E9A7D223D1D7DD05D5475BFC4C517C85475600AAF6F28703ED1203281369A41
       9A7C"""
  ]

  Ivs = [
    "F643627AA8B91D40BA644B894C7F148E",
    "F1D6521E4EE59248F7CCFA6D6C916A32",
    "937D77D24441858AF5040C9A81B3D178",
    "C7D6AE667F38A3E0C77F4AC96D82112F",
    "735E51C37802A6E72277EE74C829A84D",
    "617BAEA342062AE87B7A5D5D9F99371C",
    "B535FFA95043C90C5FEEF3654E846445",
    "3B2D2219A7EE18AB9164910821955C05",

    "DACC23805C4ED233A7100A488AB5D68F",
    "C5BFA3F8BF0D8436840D1AAAF091BD69",
    "54CA4A681AEB8B5793A450100244256F",
    "D1EB94C73D4C033EA4130B47669F4485",
    "1F1ADF6BBDE1DFC5F922D672D2344F3A",
    "A828F6D249F38A917CD297F7BDDE7B70",
    "54FC8070579A17F6DAD342174062D60A",
    "D33C7696183DA21C5CD40AB677BECE7C",

    "9EFF93741DC080A15B9E554080AB9869",
    "7A007E351C9A5C930D01645D97648F8C",
    "934DB2529D1D3AC37BAD56FD1E522196",
    "30D19C3C1AB9A3391A5F88E92307261D",
    "32ED1A961630D94A279F99757B3131CB",
    "003ABE572377D59B74713425854FED29",
    "3338850C0A4D7BD53C70E40FA0079AA2",
    "62787F194DC218C5B0DAFD806F0D3125"
  ]

  CipherKeys = [
    "8C2964320284FAD935AFEC1AFEC9EEF7",
    "622A9292256B012F3EBE814C0DB22095",
    "3171DCDBE794BB6CAADDDD71E1751F2C",
    "5E1519DFCABA2AF17AA4AA580CC1B76E",
    "8B7AC311FF7B7EA7B4E55E37688DA2BD",
    "6BB6E06A3A92D5C300598023330712D4",
    "D794A6B794C1E3501A24240D348B9A62",
    "45E2FFAC35B7647AD5045C8581F39BF0",

    "B2F8CDBD11B158DC68120E10A6D04C0B272DC3F698EB56B18094275076307CEB",
    "E0238BAA6B77646CD708DD00DE1FD17C6BB45F184348F512F4AE64E00CEA37B9",
    "CE009DE8D1C76C2793540A8B24774E09B0F84590B583F1A0551AC0CF1E911BF9",
    "ED5F14E36F4F2F80084571B24FD55C870B9C2AD937694B75B90E67D3591DC921",
    "1607CC9FF2B19E8F0CDA902D5996948E8EA8CFFA03F956038497684088A88B2F",
    "FC2797D1040FF162A90275EBA3FCC4330C2BDC28D23DA80B89842C2D7A6EFA06",
    "B83698789ED8E3B44E48EAAEB291B3003AD95FAF344EBA1B9071F4FB46A4E4E9",
    "5D90C579971B7B7F9ECDE55EBCE8921B807AAD45D61952228758BA80F4490E8F",

    "1C429A32A2E16168D3E3F942AEEAD708456C6566D800D5B7A6DCE8184739F16D",
    "84987E7CC9F71243408454DD0787F438CCB62C79ED56078FD920FFFD7D5C44FF",
    "971372E385E0F9FED8F67C922D0F5EB77D7D7818F63B26EF80C4D3C81D9E1B97",
    "F20AE0A5387B2D1D38B8B340466D252F894C00C5907EE3A510442E4F38966AB0",
    "B58F32D83C7A91B6B1DA731334D70502348CD82EFB8258C0AE316B983F2F1E1E",
    "5903FE75A1C328BE6C98EB4A4EFF19C67D3C52C87B3131047F3773201D44BFCE",
    "55EAD85B3124C36828ED3A43698952111EECE8C7FB156D71EE3F84E088B4F4CE",
    "E4C99C782A88B69E5D83F4DEFDD2AE61A397486E17EC9EAE6EC679A75E47BBCD"
  ]

  MacKeys = [
    "2C812CB8425299B485CEE0BC97778F540380F14F",
    "8AB685E8A66256480E794B0ADC09BCF4014883C8",
    "C68EF3F3102D0CEFC0924FEF17D51FABC23EA54C",
    "F177BD066555CF25327C32C807D2E44B7DAC3EFF",
    "57176FF3103FA0F4EB58B9E49133C48B4DE9BDE6",
    "0C9ECECB80DF43CA2720DD340DD992A80AAB56DB",
    "028BCC3F5559CF43DA1B0C1A03E263C90D04DD77",
    "02DAF3FF888999C6121CA50F1D49C10FF55F1ACF",

    "6F015DDA49E0DFABD5532E6CB08709CE43F326EC",
    "68C703B3867247723D21A8C58BA9109DDBB359EF",
    "6C91DBB5FE99B94A11D0937D0F4E50F2BCB248F3",
    "D5A856ECC5820D611111BE8CEAAD781E6E4E549D",
    "9DCEB01D9657A69D40B1885C392FA850486E32B3",
    "EE66A1579D732E99A8500F48595BF25289E722DB",
    "E692EC73B0A2E68625221E1D01BA0E6B24BCB43F",
    "8613E8F86D2DD1CF3CEDC52AD91423F2F31E0003",

    "F8A7EF47F37257B54A5028424E64F172E532E7E7",
    "4D3596723AECD3DF21A20E956755782E783C9E4A",
    "484860090D99F4B702C809294037E6C7F6E58BBA",
    "15163D55C0A32E79E0EDD8E8EDA5AC9564B5488C",
    "6116BCB44773E3342AB5671D2AC107D4C9EC0757",
    "1CA3FCA023C72B7695481CA815856FEF0C5D7E9E",
    "E34004C383C36201DC23E062DAE791C76738C28E",
    "FA5CB0689A1DFDBAE8618BC079D70E318377B0DA"
  ]

proc cmp(a, b: openarray[byte]): bool =
  result = (@a == @b)

proc testStretcher(s, e: int, cs: string, ds: string): bool =
  for i in s..<e:
    var sharedsecret = fromHex(stripSpaces(Secrets[i]))
    var secret = stretchKeys(cs, ds, sharedsecret)
    var iv1 = fromHex(stripSpaces(Ivs[i * 2]))
    var iv2 = fromHex(stripSpaces(Ivs[i * 2 + 1]))
    var ckey1 = fromHex(stripSpaces(CipherKeys[i * 2]))
    var ckey2 = fromHex(stripSpaces(CipherKeys[i * 2 + 1]))
    var mkey1 = fromHex(stripSpaces(MacKeys[i * 2]))
    var mkey2 = fromHex(stripSpaces(MacKeys[i * 2 + 1]))
    var r1 = cmp(secret.ivOpenArray(0), iv1) == true
    var r2 = cmp(secret.ivOpenArray(1), iv2) == true
    var r3 = secret.iv(0) == iv1
    var r4 = secret.iv(1) == iv2
    var r5 = cmp(secret.keyOpenArray(0), ckey1) == true
    var r6 = cmp(secret.keyOpenArray(1), ckey2) == true
    var r7 = secret.key(0) == ckey1
    var r8 = secret.key(1) == ckey2
    var r9 = cmp(secret.macOpenArray(0), mkey1) == true
    var rA = cmp(secret.macOpenArray(1), mkey2) == true
    var rB = secret.mac(0) == mkey1
    var rC = secret.mac(1) == mkey2
    result = r1 and r2 and r3 and r4 and r5 and r6 and r7 and r8 and
             r9 and rA and rB and rC
    if not result:
      break

suite "Key interface test suite":

  test "Go test vectors":
    for i in 0..<len(PrivateKeys):
      var seckey = PrivateKey.init(fromHex(stripSpaces(PrivateKeys[i])))
      var pubkey = PublicKey.init(fromHex(stripSpaces(PublicKeys[i])))
      var calckey = seckey.getKey()
      check:
        pubkey == calckey
      var checkseckey = seckey.getBytes()
      var checkpubkey = pubkey.getBytes()
      check:
        toHex(checkseckey) == stripSpaces(PrivateKeys[i])
        toHex(checkpubkey) == stripSpaces(PublicKeys[i])

  test "Generate/Sign/Serialize/Deserialize/Verify test":
    var msg = "message to sign"
    var bmsg = cast[seq[byte]](msg)

    for i in 0..<5:
      var seckey = PrivateKey.random(ECDSA)
      var pubkey = seckey.getKey()
      var pair = KeyPair.random(ECDSA)
      var sig1 = pair.seckey.sign(bmsg)
      var sig2 = seckey.sign(bmsg)
      var sersig1 = sig1.getBytes()
      var sersig2 = sig2.getBytes()
      var serpub1 = pair.pubkey.getBytes()
      var serpub2 = pubkey.getBytes()
      var recsig1 = Signature.init(sersig1)
      var recsig2 = Signature.init(sersig2)
      var recpub1 = PublicKey.init(serpub1)
      var recpub2 = PublicKey.init(serpub2)
      check:
        sig1.verify(bmsg, pair.pubkey) == true
        recsig1.verify(bmsg, recpub1) == true
        sig2.verify(bmsg, pubkey) == true
        recsig2.verify(bmsg, recpub2) == true

    for i in 0..<5:
      var seckey = PrivateKey.random(Ed25519)
      var pubkey = seckey.getKey()
      var pair = KeyPair.random(Ed25519)
      var sig1 = pair.seckey.sign(bmsg)
      var sig2 = seckey.sign(bmsg)
      var sersig1 = sig1.getBytes()
      var sersig2 = sig2.getBytes()
      var serpub1 = pair.pubkey.getBytes()
      var serpub2 = pubkey.getBytes()
      var recsig1 = Signature.init(sersig1)
      var recsig2 = Signature.init(sersig2)
      var recpub1 = PublicKey.init(serpub1)
      var recpub2 = PublicKey.init(serpub2)
      check:
        sig1.verify(bmsg, pair.pubkey) == true
        recsig1.verify(bmsg, recpub1) == true
        sig2.verify(bmsg, pubkey) == true
        recsig2.verify(bmsg, recpub2) == true

    for i in 0..<5:
      var seckey = PrivateKey.random(RSA, 512)
      var pubkey = seckey.getKey()
      var pair = KeyPair.random(RSA, 512)
      var sig1 = pair.seckey.sign(bmsg)
      var sig2 = seckey.sign(bmsg)
      var sersig1 = sig1.getBytes()
      var sersig2 = sig2.getBytes()
      var serpub1 = pair.pubkey.getBytes()
      var serpub2 = pubkey.getBytes()
      var recsig1 = Signature.init(sersig1)
      var recsig2 = Signature.init(sersig2)
      var recpub1 = PublicKey.init(serpub1)
      var recpub2 = PublicKey.init(serpub2)
      check:
        sig1.verify(bmsg, pair.pubkey) == true
        recsig1.verify(bmsg, recpub1) == true
        sig2.verify(bmsg, pubkey) == true
        recsig2.verify(bmsg, recpub2) == true

  test "Go key stretch function AES128-SHA256 test vectors":
    check testStretcher(0, 4, "AES-128", "SHA256") == true
  test "Go key stretch function AES256-SHA512 test vectors":
    check testStretcher(4, 8, "AES-256", "SHA512") == true
  test "Go key stretch function AES256-SHA1 test vectors":
    check testStretcher(8, 12, "AES-256", "SHA1") == true

  test "ChaChaPoly":
    # test data from:
    # https://github.com/RustCrypto/AEADs/blob/0cf02f200c8f9404979b46356a8a7b67d7c35a96/chacha20poly1305/tests/lib.rs#L66
    let
      plain =  cast[seq[byte]](@"Ladies and Gentlemen of the class of '99: If I could offer you only one tip for the future, sunscreen would be it.")
      tag: ChaChaPolyTag = [0x1a.byte, 0xe1, 0x0b, 0x59, 0x4f, 0x09, 0xe2, 0x6a, 0x7e, 0x90, 0x2e, 0xcb, 0xd0, 0x60, 0x06, 0x91]
    var
      key: ChaChaPolyKey = [0x80.byte, 0x81, 0x82, 0x83, 0x84, 0x85, 0x86, 0x87, 0x88, 0x89, 0x8a, 0x8b, 0x8c, 0x8d, 0x8e, 0x8f,
    0x90, 0x91, 0x92, 0x93, 0x94, 0x95, 0x96, 0x97, 0x98, 0x99, 0x9a, 0x9b, 0x9c, 0x9d, 0x9e, 0x9f]
      nonce: ChaChaPolyNonce = [0x07.byte, 0x00, 0x00, 0x00, 0x40, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47]
      ntag: ChaChaPolyTag # empty
      text = plain
      cipher = [0xd3.byte, 0x1a, 0x8d, 0x34, 0x64, 0x8e, 0x60, 0xdb, 0x7b, 0x86, 0xaf, 0xbc, 0x53, 0xef, 0x7e, 0xc2, 0xa4, 0xad, 0xed, 0x51, 0x29, 0x6e, 0x08, 0xfe, 0xa9, 0xe2, 0xb5, 0xa7, 0x36, 0xee, 0x62, 0xd6, 0x3d, 0xbe, 0xa4, 0x5e, 0x8c, 0xa9, 0x67, 0x12, 0x82, 0xfa, 0xfb, 0x69, 0xda, 0x92, 0x72, 0x8b, 0x1a, 0x71, 0xde, 0x0a, 0x9e, 0x06, 0x0b, 0x29, 0x05, 0xd6, 0xa5, 0xb6, 0x7e, 0xcd, 0x3b, 0x36, 0x92, 0xdd, 0xbd, 0x7f, 0x2d, 0x77, 0x8b, 0x8c, 0x98, 0x03, 0xae, 0xe3, 0x28, 0x09, 0x1b, 0x58, 0xfa, 0xb3, 0x24, 0xe4, 0xfa, 0xd6, 0x75, 0x94, 0x55, 0x85, 0x80, 0x8b, 0x48, 0x31, 0xd7, 0xbc, 0x3f, 0xf4, 0xde, 0xf0, 0x8e, 0x4b, 0x7a, 0x9d, 0xe5, 0x76, 0xd2, 0x65, 0x86, 0xce, 0xc6, 0x4b, 0x61, 0x16]
      aed = [0x50.byte, 0x51, 0x52, 0x53, 0xc0, 0xc1, 0xc2, 0xc3, 0xc4, 0xc5, 0xc6, 0xc7]

    ChaChaPoly.encrypt(key, nonce, ntag, text, aed)
    check text.toHex == cipher.toHex
    check ntag.toHex == tag.toHex
    ChaChaPoly.decrypt(key, nonce, ntag, text, aed)
    check text.toHex == plain.toHex

  test "Curve25519":
    # from https://github.com/TomCrypto/pycurve25519/blob/48ba3c58fabc4ea4f23e977474d069bb95be6776/test_curve25519.py#L5
    for _ in 0..<1024:
      var
        private: Curve25519Key
      check randomBytes(private) == Curve25519KeySize
      Curve25519.mulgen(private, private)
      check (private[0].int and (not 248)) == 0
      check (private[31].int and (not 127)) == 0
      check (private[31].int and 64) != 0

    # from bearssl test_crypto.c
    var
      res: Curve25519Key
      bearOp = fromHex("A546E36BF0527C9D3B16154B82465EDD62144C0AC1FC5A18506A2244BA449AC4")
      bearIn = fromHex("E6DB6867583030DB3594C1A424B15F7C726624EC26B3353B10A903A6D0AB1C4C")
      bearOut = fromHex("C3DA55379DE9C6908E94EA4DF28D084F32ECCF03491C71F754B4075577A28552")

    Curve25519.mul(res, bearIn.intoCurve25519Key, bearOp.intoCurve25519Key)
    check res == bearOut

    # from https://github.com/golang/crypto/blob/1d94cc7ab1c630336ab82ccb9c9cda72a875c382/curve25519/vectors_test.go#L26
    var
      private1: Curve25519Key = [0x66.byte, 0x8f, 0xb9, 0xf7, 0x6a, 0xd9, 0x71, 0xc8, 0x1a, 0xc9, 0x0, 0x7, 0x1a, 0x15, 0x60, 0xbc, 0xe2, 0xca, 0x0, 0xca, 0xc7, 0xe6, 0x7a, 0xf9, 0x93, 0x48, 0x91, 0x37, 0x61, 0x43, 0x40, 0x14]
      base: Curve25519Key = [0xdb.byte, 0x5f, 0x32, 0xb7, 0xf8, 0x41, 0xe7, 0xa1, 0xa0, 0x9, 0x68, 0xef, 0xfd, 0xed, 0x12, 0x73, 0x5f, 0xc4, 0x7a, 0x3e, 0xb1, 0x3b, 0x57, 0x9a, 0xac, 0xad, 0xea, 0xe8, 0x9, 0x39, 0xa7, 0xdd]
      public1: Curve25519Key
      public1Test: Curve25519Key = [0x9.byte, 0xd, 0x85, 0xe5, 0x99, 0xea, 0x8e, 0x2b, 0xee, 0xb6, 0x13, 0x4, 0xd3, 0x7b, 0xe1, 0xe, 0xc5, 0xc9, 0x5, 0xf9, 0x92, 0x7d, 0x32, 0xf4, 0x2a, 0x9a, 0xa, 0xfb, 0x3e, 0xb, 0x40, 0x74]

    Curve25519.mul(public1, base, private1) 
    check public1.toHex == public1Test.toHex

    # RFC vectors
    private1 = fromHex("a8abababababababababababababababababababababababababababababab6b").intoCurve25519Key
    check private1.public().toHex  == "E3712D851A0E5D79B831C5E34AB22B41A198171DE209B8B8FACA23A11C624859"
    private1 = fromHex("c8cdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcd4d").intoCurve25519Key
    check private1.public().toHex  == "B5BEA823D9C9FF576091C54B7C596C0AE296884F0E150290E88455D7FBA6126F"
    private1 = fromHex("77076d0a7318a57d3c16c17251b26645df4c2f87ebc0992ab177fba51db92c2a").intoCurve25519Key
    var
      private2 = fromHex("5dab087e624a8a4b79e17f8b83800ee66f3bb1292618b6fd1c2f8b27ff88e0eb").intoCurve25519Key
      p1Pub = private1.public()
      p2Pub = private2.public()
    check p1Pub.toHex  == "8520F0098930A754748B7DDCB43EF75A0DBF3A0D26381AF4EBA4A98EAA9B4E6A"
    check p2Pub.toHex  == "DE9EDB7D7B7DC1B4D35B61C2ECE435373F8343C85B78674DADFC7E146F882B4F"

    var
      secret1: Curve25519Key
      secret2: Curve25519Key
    Curve25519.mul(secret1, p2Pub, private1)
    Curve25519.mul(secret2, p1Pub, private2)
    check secret1.toHex == secret2.toHex

  
