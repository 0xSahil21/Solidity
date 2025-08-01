// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Person {
    string public name;
    address public wallet;
    uint public age;

    constructor(string memory _name, uint _age) {
        name = _name;
        wallet = msg.sender;
        age = _age;
    }
}

contract Instructor is Person {
    address public owner;

    constructor(string memory _name, uint _age) Person(_name, _age) {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only instructor can perform this action");
        _;
    }
}

contract StudentPortal is Instructor {
    constructor(string memory _instructorName, uint _instructorAge)
        Instructor(_instructorName, _instructorAge)
    {}

    // Enum for student status
    enum Status { Active, Graduated, Dropped }

    // Struct for student info
    struct Student {
        uint studentID;
        string name;
        address wallet;
        uint age;
        uint[] grades;
        uint attendance;
        Status status;
    }

    Student[] public students;
    uint public nextStudentID = 1;

    // Register a new student
    function registerStudent(string memory _name, address _wallet, uint _age) public onlyOwner {
        students.push(Student({
            studentID: nextStudentID,
            name: _name,
            wallet: _wallet,
            age: _age,
            grades: new uint256[](0) ,
            attendance: 0,
            status: Status.Active
        }));
        nextStudentID++;
    }

    // Find student index by ID
    function findStudentIndex(uint studentID) internal view returns (uint) {
        for (uint i = 0; i < students.length; i++) {
            if (students[i].studentID == studentID) {
                return i;
            }
        }
        revert("Student not found");
    }

    // Assign grade
    function assignGrade(uint studentID, uint grade) public onlyOwner {
        uint index = findStudentIndex(studentID);
        students[index].grades.push(grade);
    }

    // Mark attendance
    function markAttendance(uint studentID) public onlyOwner {
        uint index = findStudentIndex(studentID);
        students[index].attendance += 1;
    }

    // Calculate average grade
    function getAverageGrade(uint studentID) public view returns (uint) {
        uint index = findStudentIndex(studentID);
        Student storage s = students[index];
        uint total = 0;
        uint count = s.grades.length;

        for (uint i = 0; i < count; i++) {
            total += s.grades[i];
        }

        return count == 0 ? 0 : total / count;
    }

    // Update student info (name, age, status)
    function updateStudentInfo(uint studentID, string memory _newName, uint _newAge, Status _newStatus) public onlyOwner {
        uint index = findStudentIndex(studentID);
        Student storage s = students[index];
        s.name = _newName;
        s.age = _newAge;
        s.status = _newStatus;
    }

    // Get total number of students
    function getTotalStudents() public view returns (uint) {
        return students.length;
    }
}
