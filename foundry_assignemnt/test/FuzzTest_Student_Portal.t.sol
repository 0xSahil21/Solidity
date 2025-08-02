// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Student_Portal.sol";

contract FuzzTest_Student_Portal is Test {
    StudentPortal portal;

    address owner;
    address outsider;

    function setUp() public {
        owner = address(this);
        outsider = address(0xBEEF);
        portal = new StudentPortal();
    }

    /// @dev Fuzz registering multiple students with various names and ages
    function testFuzz_RegisterStudent(string memory name, uint256 age, address student) public {
        vm.assume(student != address(0));
        vm.assume(age > 10 && age < 120); // realistic age

        portal.registerStudent(name, age, student);
        (string memory storedName, uint256 storedAge, address storedWallet, ) = portal.getStudent(student);

        assertEq(storedName, name);
        assertEq(storedAge, age);
        assertEq(storedWallet, student);
        //assertTrue(portal.students(student).isRegistered);
    }

    /// @dev Fuzz grades and test average calculation
    function testFuzz_GradeAverage(address student, uint256 grade1, uint256 grade2, uint256 grade3) public {
        vm.assume(student != address(0));
        grade1 = grade1 % 101;
        grade2 = grade2 % 101;
        grade3 = grade3 % 101;

        portal.registerStudent("Fuzzer", 20, student);
        portal.addGrade(student, grade1);
        portal.addGrade(student, grade2);
        portal.addGrade(student, grade3);

        uint256 expectedAverage = (grade1 + grade2 + grade3) / 3;
        uint256 actualAverage = portal.getAverageGrade(student);

        assertEq(actualAverage, expectedAverage);
    }

    /// @dev Fuzz adding attendance multiple times
    function testFuzz_Attendance(address student, uint256 count) public {
        vm.assume(student != address(0));
        vm.assume(count > 0 && count < 1000); // reasonable limit

        portal.registerStudent("Attendee", 19, student);

        for (uint256 i = 0; i < count; i++) {
            portal.addAttendance(student);
        }

        (, , , uint256 storedAttendance) = portal.getStudent(student);
        assertEq(storedAttendance, count);
    }

    /// @dev Ensure non-owner cannot register students
    function testFuzz_RevertWhen_NonOwnerTriesToRegister(address newOwner, address student) public {
        vm.assume(student != address(0));
        vm.assume(newOwner != address(0) && newOwner != address(this));

        vm.prank(newOwner);
        vm.expectRevert(bytes("Not Authorized, as not the contract owner"));
        portal.registerStudent("Hacker", 99, student);
    }

    /// @dev Ensure cannot register same student twice
    function testFuzz_RevertWhen_RegisteringDuplicateStudent(address student) public {
        vm.assume(student != address(0));

        portal.registerStudent("Student", 22, student);

        vm.expectRevert(bytes("Student already registered"));
        portal.registerStudent("Student", 22, student);
    }

    /// @dev Fuzz multiple student registrations and verify count
    function testFuzz_TotalStudentCount(uint8 count) public {
        vm.assume(count > 0 && count <= 100); // safe upper limit

        for (uint8 i = 0; i < count; i++) {
            address student = address(uint160(uint256(keccak256(abi.encode(i)))));
            portal.registerStudent("Batch", 18 + i, student);
        }

        assertEq(portal.totalStudents(), count);
    }
}
