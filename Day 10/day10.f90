! gfortran -std=f95 -Wextra -Wall -pedantic day10.f90 && ./a.out

program day10
  implicit none

  integer :: ios
  integer, parameter :: file_handle = 99
  character(len=100000) :: line

  ! -- variables for execution
  integer :: pos = 1
  character :: dummy_closingToken = "I"
  logical :: isEofLine, isCorrupt, isIncomplete

  integer(kind = 8) :: errorCostPartOne = 0
  integer(kind = 8) :: errorCostPartTwo = 0

  ! -- variables for list
  integer(kind = 8), dimension(1000) :: errorsPartTwo
  integer :: numErrorsPartTwo = 0

  integer :: i

  open(unit=file_handle, file='input.txt', iostat=ios)
  if ( ios /= 0 ) stop "Error opening file data.dat"

  rewind(file_handle)

  do
    print*, "---------------"
    read(file_handle, '(A)', iostat=ios) line

    if (ios /= 0) exit
    
    print*, LEN_TRIM(line)

    pos = 1
    errorCostPartTwo = 0
    isEofLine = .false.
    isCorrupt = .false.
    isIncomplete = .false.    
    call parse(line, pos, LEN_TRIM(line), dummy_closingToken, isEofLine, isCorrupt, isIncomplete)

    print*, "isEofLine: ", isEofLine, ", isCorrupt: ",isCorrupt, ",isIncomplete:", isIncomplete
    print*, "the accumulated costs (part one) are ", errorCostPartOne
    print*, "the current costs     (part two) is  ", errorCostPartTwo

    ! add to list
    if(errorCostPartTwo > 0) then
      numErrorsPartTwo = numErrorsPartTwo + 1
      errorsPartTwo(numErrorsPartTwo) = errorCostPartTwo
    endif
  end do

  close(file_handle)

  call sort()

  i = 1
  do 
    if (i > numErrorsPartTwo) then
      exit
    endif
    
    print*, "item ", i, " is ", errorsPartTwo(i)

    i = i + 1
  end do

  print*, "solution part 2 is ", errorsPartTwo((numErrorsPartTwo + 1)/2)

contains

  recursive subroutine parse(line, pos, len, closingToken, isEofLine, isCorrupt, isIncomplete)
    implicit none

    ! -- params
    character(len=*), intent(in) :: line
    integer, intent(in) :: len
    ! -- out
    integer, intent(inout) :: pos
    logical, intent(inout) :: isEofLine, isCorrupt, isIncomplete
    character, intent(out) :: closingToken
    
    ! -- declare variables
    character :: currentToken
    character :: resultToken
    
    do
      if(pos > len) then
        print*, "End of line"
        closingToken = 'E' ! means end of file

        isEofLine = .true.
        isCorrupt = .false.
        isIncomplete = .false.

        return
      endif

      currentToken = line(pos:pos+1)

      ! closing -> too much on this stage -> go one step back
      if(is_closing(currentToken)) then
        closingToken = currentToken
        return
      endif

      ! opening -> go one stage down -> check results
      if(is_opening(currentToken)) then
        pos = pos + 1
        call parse(line, pos, len, resultToken, isEofLine, isCorrupt, isIncomplete)
        
        if (isCorrupt) then
          return
        endif

        if (isIncomplete) then
          print*, "repair with ", get_expected_closing_char_from(currentToken)
          errorCostPartTwo = errorCostPartTwo * 5 + get_cost_for_missing(get_expected_closing_char_from(currentToken))
          return
        endif

        if (.not. do_match(currentToken, resultToken)) then ! handle just first incorrect token
          print*, "error on position ", pos, ": expected ", get_expected_closing_char_from(currentToken), " but was ", resultToken

          if (.not. resultToken == "E") then
            print*, "corrupt line"
            errorCostPartOne = errorCostPartOne + get_costs_for_illegal(resultToken)

            isEofLine = .false.
            isCorrupt = .true.
            isIncomplete = .false.
          endif
          
          if(resultToken == "E") then
            print*, "incomplete line"
            errorCostPartTwo = errorCostPartTwo * 5 + get_cost_for_missing(get_expected_closing_char_from(currentToken))

            isEofLine = .true.
            isCorrupt = .false.
            isIncomplete = .true.
          endif
          return
        endif
      endif

      pos = pos + 1
    end do
  end subroutine

  pure function is_opening( token )
    implicit none

    character (len=1), intent (in) :: token
    logical :: is_opening

    is_opening = .false.

    if (token == "(" .or. token == "[" .or. token == "{" .or. token == "<") then
      is_opening = .true.
    endif
  end function is_opening

  pure function is_closing( token )
    implicit none

    character (len=1), intent (in) :: token
    logical :: is_closing

    is_closing = .false.

    if (token == ")" .or. token == "]" .or. token == "}" .or. token == ">") then
      is_closing = .true.
    endif
  end function is_closing

  pure function do_match(openingToken, closingToken) 
    implicit none

    character, intent(in) :: openingToken, closingToken
    logical :: do_match

    do_match = (closingToken == get_expected_closing_char_from(openingToken))

  end function do_match

  pure function get_costs_for_illegal(closingToken)
    implicit none

    character, intent(in) :: closingToken
    integer :: get_costs_for_illegal

    select case (closingToken)
      case(")")
        get_costs_for_illegal = 3
      case ("]")
        get_costs_for_illegal = 57
      case ("}")
        get_costs_for_illegal = 1197
      case (">")
        get_costs_for_illegal = 25137
    end select
  end function get_costs_for_illegal

  pure function get_expected_closing_char_from(openingToken) 
    implicit none

    character, intent(in) :: openingToken
    character :: get_expected_closing_char_from

    select case (openingToken)
      case("(")
        get_expected_closing_char_from = ")"
      case ("[")
        get_expected_closing_char_from = "]"
      case ("{")
        get_expected_closing_char_from = "}"
      case ("<")
        get_expected_closing_char_from = ">"
    end select
  end function get_expected_closing_char_from

  pure function get_cost_for_missing(closingToken)
    implicit none

    character, intent(in) :: closingToken
    integer :: get_cost_for_missing

    select case (closingToken)
      case(")")
        get_cost_for_missing = 1
      case ("]")
        get_cost_for_missing = 2
      case ("}")
        get_cost_for_missing = 3
      case (">")
        get_cost_for_missing = 4
    end select
  end function get_cost_for_missing

  subroutine sort()
    implicit none

    ! -- variables
    integer :: i = 1, ii = 1
    integer :: minIndex = 0
    integer(kind = 8) :: minVal
    integer(kind = 8) :: tmp

    do
      if(i >= numErrorsPartTwo) exit

      ii = i
      minIndex = i
      minVal = errorsPartTwo(i)

      do
        if(ii > numErrorsPartTwo) exit

        if(minVal > errorsPartTwo(ii)) then
          minVal = errorsPartTwo(ii)
          minIndex = ii
        endif
        
        ii = ii + 1
      end do

      tmp = errorsPartTwo(i)
      errorsPartTwo(i) = minVal
      errorsPartTwo(minIndex) = tmp

      i = i +1
    end do
  end subroutine

end program day10