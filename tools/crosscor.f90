program crosscor
use sacio
use module_crosscor
implicit none
character(len=2) :: q
character(len=1024) :: arg
character(len=:) ,allocatable :: file, out
integer :: i, flag
real,allocatable,dimension(:) :: x, y, result
type(sachead) :: headx, heady, head

do i=1,3
    call get_command_argument(i, arg)
    q = arg(1:2)
    file = arg(3:len(arg))
    select case (arg(1:2))
    case ('-X')
        call sacio_readsac(file, headx, x, flag)
    case ('-Y')
        call sacio_readsac(file, heady, y, flag)
    case ('-O')
        out = file
    case default
        flag = 1
    end select
end do

if (headx%delta /= heady%delta) then
    flag = 1
    write(*,*) "sacio_Fortran: delta is not equal in -X file and -Y file"
end if
if (headx%npts < heady%npts) then
    flag = 1
    write(*,*) "sacio_Fortran: npts in -X file is smaller than -Y file"
end if

if (flag == 0) then
    call sub_crosscor(x, y, result, flag)
end if
call sacio_newhead(head, headx%delta, size(result), headx%b - heady%e + (heady%npts - 1) * headx%delta)
if (flag == 0) then
    call sacio_writesac(out, head, result, flag)
end if

end program crosscor