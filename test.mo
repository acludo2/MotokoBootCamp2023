import Time "mo:base/Time";
import Buffer "mo:base/Buffer";
import Text "mo:base/Text";
import Result "mo:base/Result";

actor {
  var homeworkDiary = Buffer.Buffer<Homework>(0);
  type Time = Int;

  type Homework = {
    title : Text;
    description : Text;
    dueDate : Time;
    completed : Bool;
  };

  //LISTO addHomework: shared (homework: Homework) -> async Nat;
  public shared func addHomework(homework : Homework) : async Nat {
    homeworkDiary.add(homework);
    return homeworkDiary.size();
  };
  //LISTO getHomework: shared query (id: Nat) -> async Result.Result<Homework, Text>;
  public shared query func getHomework(id : Nat) : async Result.Result<Homework, Text> {
    if (homeworkDiary.getOpt(id) != null) {
      #ok(homeworkDiary.get(id));
    } else {
      #err("Homework id does not exist");
    };
  };
  //LISTO updateHomework: shared (id: Nat, homework: Homework) -> async Result.Result<(), Text>;
  public shared func updateHomework(id: Nat, homework: Homework) : async Result.Result<(), Text> {
    if (homeworkDiary.getOpt(id) != null) {
      #ok(homeworkDiary.put(id, homework));
    } else {
      #err("Homework id does not exist");
    };
  };
  //LISTO markAsCompleted: shared (id: Nat) -> async Result.Result<(), Text>;
  public shared func markAsCompleted(id : Nat) : async Result.Result<(), Text> {
    if (homeworkDiary.getOpt(id) != null) {
      var updatedHomework = homeworkDiary.get(id);
      updatedHomework := {
        completed = true;
        description = updatedHomework.description;
        dueDate = updatedHomework.dueDate;
        title = updatedHomework.title;
      };
      homeworkDiary.put(id, updatedHomework);
      return #ok();
    } else {
      return #err("Homework id does not exist");
    };
  };
  //LISTO deleteHomework: shared (id: Nat) -> async Result.Result<(), Text>;
  public shared func deleteHomework(id : Nat) : async Result.Result<(), Text> {
    if (homeworkDiary.getOpt(id) != null) {
      let test = homeworkDiary.remove(id);
      #ok;
    } else {
      #err "There is no Homework with that ID.";
    };
  };
  //LISTO getAllHomework: shared query () -> async [Homework];
  public shared query func getAllHomework() : async [Homework] {
    return Buffer.toArray(homeworkDiary);
  };

  //LISTO getPendingHomework: shared query () -> async [Homework];
  public shared query func getPendingHomework() : async [Homework] {
    var id = 0;
    var homeworkDiaryPending = Buffer.Buffer<Homework>(0);
    for (element in homeworkDiary.vals()) {
      if (element.completed == false) {
          homeworkDiaryPending.add(homeworkDiary.get(id));
      };
    };
    Buffer.toArray(homeworkDiaryPending);
  };

  //searchHomework: shared query (searchTerm: Text) -> async [Homework];
  public shared query func searchHomework(searchTerm: Text) : async [Homework] {
    var id = 0;
    var homeworkDiaryPending = Buffer.Buffer<Homework>(0);
    for (element in homeworkDiary.vals()) {
      if (Text.contains(element.title, #text searchTerm) == true or Text.contains(element.description, #text searchTerm) == true ) {
          homeworkDiaryPending.add(homeworkDiary.get(id));
      };
    };
    return Buffer.toArray(homeworkDiaryPending);
  };
};