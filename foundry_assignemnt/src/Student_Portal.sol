//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//Project Title : Student Portal - An academic record management system using address based student mapping

contract Person {
    struct BasicInfo {
        string name;
        uint age;
        address wallet;
    }

    address public owner;

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Not Authorized, as not the contract owner"
        );
        _;
    }

    constructor() {
        owner = msg.sender; // The address that deploys the contract becomes the owner
    }
}

contract StudentPortal is Person {
    struct Student {
        BasicInfo info;
        uint256[] grades;
        uint256 attendance;
        bool isRegistered;
    }

    mapping(address => Student) public students; // maps student wallet to their academic records

    address[] public studentList; //keeps track of all registered students

    event StudentRegistered(address wallet, string name);
    event GradeAdded(address indexed student, uint256 grade);
    event AttendanceMarked(address indexed student);

    function registerStudent(
        string memory _name,
        uint _age,
        address _wallet
    ) public onlyOwner {
        require(!students[_wallet].isRegistered, "Student already registered");

        students[_wallet] = Student({
            info: BasicInfo({name: _name, age: _age, wallet: _wallet}),
            grades: new uint256[](0),
            attendance: 0,
            isRegistered: true
        });

        studentList.push(_wallet);

        emit StudentRegistered(_wallet, _name);
    }

    function addGrade(address _student, uint256 _grade) public onlyOwner {
        require(students[_student].isRegistered, "Student not registered");

        students[_student].grades.push(_grade);

        emit GradeAdded(_student, _grade);
    }

    function addAttendance(address _student) public onlyOwner {
        require(students[_student].isRegistered, "Student not registered");

        students[_student].attendance += 1;

        emit AttendanceMarked(_student);
    }

    function getStudent(
        address _student
    )
        public
        view
        returns (
            string memory name,
            uint256 age,
            address wallet,
            uint256 attendance
        )
    {
        require(students[_student].isRegistered, "Student not registered");
        Student storage s = students[_student];
        return (s.info.name, s.info.age, s.info.wallet, s.attendance);
    }

    function getAverageGrade(address _student) public view returns (uint256) {
        require(students[_student].isRegistered, "Student not registered");
        Student storage s = students[_student];

        if (s.grades.length == 0) return 0;
        uint256 total = 0;

        for (uint256 i = 0; i < s.grades.length; i++) {
            total += s.grades[i];
        }

        return total / s.grades.length;
    }

    function getAllStudents() public view returns (address[] memory) {
        return studentList;
    }

    function totalStudents() public view returns (uint256) {
        return studentList.length;
    }
}
