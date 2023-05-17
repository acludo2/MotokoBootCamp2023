import Account "./account";
import Text "mo:base/Text";
import Hash "mo:base/Hash";
import Principal "mo:base/Principal";
import Nat "mo:base/Nat";
import TrieMap "mo:base/TrieMap";
import Result "mo:base/Result";
import Buffer "mo:base/Buffer";
import Blob "mo:base/Blob";
import Array "mo:base/Array";



actor MotoCoin {
    let coinName:Text = "MotoCoin";
    let coinSymbol:Text = "MOC";
    var coinSupply:Nat = 10000000;
    public type Subaccount = Blob;
    private var canisterId = "rww3b-zqaaa-aaaam-abioa-cai";
    public type PrincipalArray = [Principal];

     var scope1 = 0;
     var scope2 = 0;
     var scope3 = 0;

       public shared query func seescope1(): async Nat{
        return scope1;
        };

        public shared query func seescope2(): async Nat{
        return scope2;
        };

           public shared query func seescope3(): async Nat{
            return scope3;
        };

    var ledger = TrieMap.TrieMap<Account.Account,Nat>(Account.accountsEqual,Account.accountsHash);




    let textPrincipals: [Text] = [
        "un4fu-tqaaa-aaaab-qadjq-cai",
        "un4fu-tqaaa-aaaac-qadjr-cai",
        "un4fu-tqaaa-aaaad-qadjs-cai",
        "un4fu-tqaaa-aaaae-qadjt-cai",
        "un4fu-tqaaa-aaaaf-qadjv-cai",
        "un4fu-tqaaa-aaaag-qadjw-cai",
        "un4fu-tqaaa-aaaah-qadjx-cai",
        "un4fu-tqaaa-aaaai-qadjy-cai",
        "un4fu-tqaaa-aaaaj-qadjz-cai",
        "un4fu-tqaaa-aaaak-qadk1-cai",
    ];


     public shared func getAllStudentsPrincipalTest():async[Principal]{
             let principalsText:Buffer.Buffer<Text> = Buffer.fromArray(textPrincipals);
             var index:Nat = 0;
             var principalsReady = Buffer.Buffer<Principal>(10);

                  Buffer.iterate<Text>(principalsText, func (x) {
                      let newPrincipal = Principal.fromText(principalsText.get(index));
                    principalsReady.add(newPrincipal);
            });
            /* while(index<= principalsText.size()-1){
                let newPrincipal = Principal.fromText(principalsText.get(index));
                principalsReady.put(index,newPrincipal);
                index += 1;
             };*/
            return Buffer.toArray(principalsReady);
    };




    public shared query func name(): async Text{
        return coinName;
    };


    public shared query func symbol(): async Text{
        return coinSymbol;
    };

    public shared query func totalSupply(): async Nat{
        return coinSupply;
    };

    private func getBalance(account:Account.Account):Nat{
     switch (ledger.get(account)) {
      case null { return 0 };
      case (?coins) { return coins};
    };
    };

    public shared query func balanceOf(account:Account.Account): async (Nat) {
      return getBalance(account);
    };

    private func _transfer(from:Account.Account,to:Account.Account,amount:Nat){
        var fromCoins = getBalance(from);
        fromCoins:= fromCoins-amount;
        ledger.put(from,fromCoins);
        var toCoins = getBalance(to);
        toCoins:= toCoins+amount;
        ledger.put(to,toCoins);
    };


    private func _airDrop(to:Account.Account){
           if (coinSupply >= 100) {
            coinSupply -= 100;
            var toCoinsAirdrop = 100;
                            scope2 += 1;
           ledger.put(to, toCoinsAirdrop);
        }
    };

    private func _defaultSub():Subaccount{
        return Blob.fromArrayMut(Array.init(32, 0 : Nat8));
    };


     public func getStudents():async PrincipalArray {
        let canister2 = actor(canisterId): actor { getAllStudentsPrincipal : shared () -> async [Principal];};
        var students = await canister2.getAllStudentsPrincipal();
        return students;
    };

    public shared func airDrop(): async Result.Result<(),Text>{
            var studentsCanister:PrincipalArray =  await getStudents();
              let studentsPrincipals:Buffer.Buffer<Principal> = Buffer.fromArray(studentsCanister);
            var index =0;
                while(index < studentsPrincipals.size()){
                    let defaultSub:Account.Subaccount = _defaultSub();
                        var student= studentsPrincipals.get(index);
                        let newAccount:Account.Account = {
                            owner=student;
                            subaccount=?defaultSub;
                        };
                       _airDrop(newAccount);
                        index += 1;
                };
            return #ok()
    };


    public shared func airDrop2(): async Result.Result<(),Text>{
            var students = await getAllStudentsPrincipalTest();
            let studentsPrincipals:Buffer.Buffer<Principal> = Buffer.fromArray(students);
              Buffer.iterate<Principal>(studentsPrincipals, func (x) {
                    let defaultSub:Account.Subaccount = _defaultSub();
                        let newAccount:Account.Account = {
                            owner=x;
                            subaccount=?defaultSub;
                        };
                        _airDrop(newAccount);
            });

            return #ok()
    };





    public shared(msg) func transfer(from:Account.Account,to:Account.Account,amount:Nat): async Result.Result<(),Text>{
        switch (ledger.get(from)) {
        case null { return #err "insufficient balance or non existing account" };
        case (?coins) {
            if(coins>=amount){
                    _transfer(from,to,amount)
            };
            return #err "insuficient balance to perform operation"
        };
        };
    };

};