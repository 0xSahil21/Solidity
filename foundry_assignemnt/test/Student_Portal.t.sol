// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Student_Portal.sol";

contract StudentPortalTest is Test {
    StudentPortal portal;
    address owner;
    address student1;
    address student2;
    address outsider;

    function setUp() public {
        owner = address(this); 
        student1 = address(0x1);
        student2 = address(0x2);
        outsider = address(0x3);

        portal = new StudentPortal();
    }

    
    function testRegisterStudent() public {
        portal.registerStudent("Alice", 20, student1);
        (string memory name,, address wallet,) = portal.getStudent(student1);

        assertEq(name, "Alice");
        assertEq(wallet, student1);
        assertEq(portal.totalStudents(), 1);
    }

    function test_RevertWhen_RegisteringSameStudentTwice() public {
        portal.registerStudent("Alice", 20, student1);
        vm.expectRevert(bytes("Student already registered"));
        portal.registerStudent("Alice Again", 21, student1);
    }

    function test_RevertWhen_NonOwnerTriesToRegister() public {
        vm.prank(outsider);
        vm.expectRevert(bytes("Not Authorized, as not the contract owner"));
        portal.registerStudent("Bob", 22, student2);
    }

    
    function testAddGrade() public {
        portal.registerStudent("Alice", 20, student1);
        portal.addGrade(student1, 85);
        portal.addGrade(student1, 90);

        uint256 avg = portal.getAverageGrade(student1);
        assertEq(avg, 87);
    }

    function test_RevertWhen_AddGradeForUnregisteredStudent() public {
        vm.expectRevert(bytes("Student not registered"));
        portal.addGrade(student1, 100);
    }

    function test_RevertWhen_NonOwnerAddsGrade() public {
        portal.registerStudent("Alice", 20, student1);
        vm.prank(outsider);
        vm.expectRevert(bytes("Not Authorized, as not the contract owner"));
        portal.addGrade(student1, 88);
    }

    
    function testAddAttendance() public {
        portal.registerStudent("Alice", 20, student1);
        portal.addAttendance(student1);
        portal.addAttendance(student1);

        (, , , uint256 attendance) = portal.getStudent(student1);
        assertEq(attendance, 2);
    }

    function test_RevertWhen_AddAttendanceToUnregisteredStudent() public {
        vm.expectRevert(bytes("Student not registered"));
        portal.addAttendance(student2);
    }

    function test_RevertWhen_NonOwnerAddsAttendance() public {
        portal.registerStudent("Alice", 20, student1);
        vm.prank(outsider);
        vm.expectRevert(bytes("Not Authorized, as not the contract owner"));
        portal.addAttendance(student1);
    }

    
    function testGetStudentDetails() public {
        portal.registerStudent("Alice", 20, student1);
        (string memory name, uint age, address wallet, uint attendance) = portal.getStudent(student1);

        assertEq(name, "Alice");
        assertEq(age, 20);
        assertEq(wallet, student1);
        assertEq(attendance, 0);
    }

    function test_RevertWhen_GettingUnregisteredStudent() public {
        vm.expectRevert(bytes("Student not registered"));
        portal.getStudent(student2);
    }

    function testGetAverageGradeEmpty() public {
        portal.registerStudent("Alice", 20, student1);
        uint256 avg = portal.getAverageGrade(student1);
        assertEq(avg, 0);
    }

    function test_RevertWhen_GetAverageGradeForUnregisteredStudent() public {
        vm.expectRevert(bytes("Student not registered"));
        portal.getAverageGrade(student2);
    }

    function testGetAllStudents() public {
        portal.registerStudent("Alice", 20, student1);
        portal.registerStudent("Bob", 22, student2);

        address[] memory list = portal.getAllStudents();
        assertEq(list.length, 2);
        assertEq(list[0], student1);
        assertEq(list[1], student2);
    }

    function testTotalStudents() public {
        assertEq(portal.totalStudents(), 0);
        portal.registerStudent("Alice", 20, student1);
        assertEq(portal.totalStudents(), 1);
    }
}
