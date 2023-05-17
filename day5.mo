import HashMap "mo:base/HashMap";
import Text "mo:base/Text";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Iter "mo:base/Iter";
import Buffer "mo:base/Buffer";
import ManagementCanister "ic";
import Error "mo:base/Error";
import Int "mo:base/Int";



actor{
    type ManagementCanister = ManagementCanister.ManagementCanister;


    public type StudentProfile = {
    name : Text;
    Team : Text;
    graduate : Bool;
    };

    public type TestResult = Result.Result<(), TestError>;
    public type TestError = {
        #UnexpectedValue : Text;
        #UnexpectedError : Text;
    };

    stable var entries:[(Principal,StudentProfile)]=[];

   var studentsProfileStore = HashMap.fromIter<Principal,StudentProfile>(entries.vals(),entries.size(),Principal.equal,Principal.hash);

    system func preupgrade() {
        entries := Iter.toArray(studentsProfileStore.entries());
    };

    system func postupgrade() {
        entries := [];
    };



   public shared(msg) func addMyProfile(student:StudentProfile):async Result.Result<(),Text>{
            switch(studentsProfileStore.get(msg.caller)){
                case null { #ok(studentsProfileStore.put(msg.caller,student))};
                case studentFound { #err "student already registered"};
            }
   };


    public shared query func seeAProfile(p:Principal):async Result.Result<StudentProfile,Text>{
            switch(studentsProfileStore.get(p)){
                case null {#err "student not found"};
                case (?found) {return #ok(found)};
            }
    };

    public shared(msg) func updateMyProfile(profile:StudentProfile): async Result.Result<(),Text>{
            switch(studentsProfileStore.get(msg.caller)){
                case null { #err"student profile doesnt exist"};
                case(?found){
                    studentsProfileStore.put(msg.caller,profile);
                    #ok()
                    };
            }
    };




    public shared(msg) func deleteMyProfile():async Result.Result<(),Text>{
            switch(studentsProfileStore.remove(msg.caller)){
                case null {#err"the student doesnt exist so it cant be deleted"};
                case(?found){
                    #ok()
                }
            }
    };


      public func parseControllersFromCanisterStatusErrorIfCallerNotController(errorMessage : Text) : async [Principal] {
        let lines = Iter.toArray(Text.split(errorMessage, #text("\n")));
        let words = Iter.toArray(Text.split(lines[1], #text(" ")));
        var i = 2;
        let controllers = Buffer.Buffer<Principal>(0);
        while (i < words.size()) {
        controllers.add(Principal.fromText(words[i]));
        i += 1;
        };
        Buffer.toArray<Principal>(controllers);
  };




    public shared func test(canisterId:Principal):async TestResult{
        let canisterToTest = actor(Principal.toText(canisterId)):actor{
            add: shared(n:Int)->async Int;
            sub: shared(n:Nat)->async Int;
            reset: shared()->async Int;
        };
        try {
            let testReset = await canisterToTest.reset();
            if(testReset!=0){
                let testTextFail:Text = "expected 0 got"#Int.toText(testReset);
                let testFail: TestError = #UnexpectedValue testTextFail;
                return #err testFail;
                };

            let testAdd = await canisterToTest.add(2);
            if(testAdd!=2){
            let testTextFail:Text = "expected 0 got"#Int.toText(testAdd);
            let testFail: TestError = #UnexpectedValue testTextFail;
            return #err testFail;
            };


            let testSub = await canisterToTest.sub(2);
                if(testSub!=0){
                    let testTextFail:Text = "expected 0 got"#Int.toText(testSub);
                    let testFail: TestError = #UnexpectedValue testTextFail;
                    return #err testFail;
            };
          return #ok
        } catch (e) {
            let textMssg:Text = Error.message(e);
            let errorMessage :TestError = #UnexpectedError textMssg;
            return #err errorMessage;

        };
    };









      public shared func verifyOwnership(canisterId:Principal,principalId:Principal):async Bool {
        let called = actor("aaaaa-aa"): ManagementCanister;
        try {
                let foo = await called.canister_status({canister_id=canisterId});
                return false;
            } catch (e) {
                    let canisterControllers = await parseControllersFromCanisterStatusErrorIfCallerNotController(Error.message(e));
                    let canisterControllersBuffer = Buffer.fromArray<Principal>(canisterControllers);
                    var returnBool:Bool = false;
                    Buffer.iterate(canisterControllersBuffer, func (x:Principal) {
                        if(x==principalId){
                            returnBool := true;
                        }
            });
                return returnBool;
            };
    };

    public func peformGraduation(principalid:Principal){
         switch(studentsProfileStore.get(principalid)){
                case null {};
                case(?found){
                    let profile={
                         name=found.name;
                        Team=found.Team;
                        graduate=true;
                    };
                    studentsProfileStore.put(principalid,profile);
                    };
            }
    };


    public shared func verifyWork(canisterId:Principal,principalId:Principal):async Result.Result<(),Text>{
                let owner = await verifyOwnership(canisterId,principalId);
                let testCall = await test(canisterId);
                if(Result.isOk(testCall) and owner==true){
                    return #ok(());
                };
            return #err"no quite there yet";
    };



}