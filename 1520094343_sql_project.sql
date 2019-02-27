/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */

select Facilities.name
from country_club.Facilities
where membercost>0
/*
result:
Tennis Court 1
Tennis Court 2
Massage Room 1
Massage Room 2
Squash Court
*/

/* Q2: How many facilities do not charge a fee to members? */

select count(distinct Facilities.name)
from country_club.Facilities
where membercost=0

/*
result:
4
*/

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */
select Facilities.facid, Facilities.name, Facilities.membercost,
Facilities.monthlymaintenance
from country_club.Facilities
where membercost< monthlymaintenance*0.2

/*Result

facid
name
membercost
monthlymaintenance


0
Tennis Court 1
5.0
200

1
Tennis Court 2
5.0
200


2
Badminton Court
0.0
50


3
Table Tennis
0.0
10

4
Massage Room 1
9.9
3000


5
Massage Room 2
9.9
3000

6
Squash Court
3.5
80


7
Snooker Table
0.0
15

8
Pool Table
0.0
15

*/

/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */
select Facilities.facid, Facilities.name, Facilities.membercost,
Facilities.monthlymaintenance
from country_club.Facilities
where facid in (1,5)

/*result:
facid
name
membercost
monthlymaintenance


1
Tennis Court 2
5.0
200


5
Massage Room 2
9.9
3000

*/
/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */
select Facilities.name, Facilities.monthlymaintenance,
case
	when Facilities.monthlymaintenance>100 then 'Expensive'
	else 'Cheap'
end as Label
from country_club.Facilities

/*Results
Tennis Court 1
200
Expensive
Tennis Court 2
200
Expensive
Badminton Court
50
Cheap
Table Tennis
10
Cheap
Massage Room 1
3000
Expensive
Massage Room 2
3000
Expensive
Squash Court
80
Cheap
Snooker Table
15
Cheap
Pool Table
15
Cheap
*/

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */
select Members.firstname, Members.surname, Members.joindate
from country_club.Members
where Members.joindate=(select max(Members.joindate) from country_club.Members)

/* Result:

firstname
surname
joindate
Darren
Smith
2012-09-26 18:08:45

*/

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

select concat(Members.firstname,' ',Members.surname) as Fullname, Facilities.name
from country_club.Bookings
join country_club.Members on Bookings.memid=Members.memid
Join country_club.Facilities on Bookings.facid=Facilities.facid
where Facilities.name in ('Tennis Court 1', 'Tennis Court 2')
group by Bookings.memid, Bookings.facid
order by Fullname

/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */
select Facilities.name, concat(Members.firstname,' ',Members.surname) as Fullname, case when Bookings.memid=0 then guestcost*slots else membercost*slots end as cost
from country_club.Bookings
join country_club.Members on Bookings.memid=Members.memid
Join country_club.Facilities on Bookings.facid=Facilities.facid
where date(starttime)='2012-09-14'
and (case when Bookings.memid=0 then guestcost*slots>30 else membercost*slots>30 end)
order by cost desc

/* Q9: This time, produce the same result as in Q8, but using a subquery. */
select member, facility, cost from (
	select 
		concat(Members.firstname,' ',Members.surname) as member,
		Facilities.name as facility,
		case
			when Members.memid = 0 then
				Bookings.slots*Facilities.guestcost
			else
				Bookings.slots*Facilities.membercost
		end as cost
		from
			country_club.Members
			 join country_club.Bookings 
				on Members.memid = Bookings.memid
			 join country_club.Facilities
				on Bookings.facid = Facilities.facid
		where
			date(starttime)='2012-09-14'
	) as bks
	where cost > 30
order by cost desc

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */
