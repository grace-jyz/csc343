import java.sql.*;
import java.util.List;

// If you are looking for Java data structures, these are highly useful.
// Remember that an important part of your mark is for doing as much in SQL (not Java) as you can.
// Solutions that use only or mostly Java will not receive a high mark.
import java.util.ArrayList;
//import java.util.Map;
//import java.util.HashMap;
//import java.util.Set;
//import java.util.HashSet;
public class Assignment2 extends JDBCSubmission {
    public Assignment2() throws ClassNotFoundException {
        Class.forName("org.postgresql.Driver");
    }

    @Override
    public boolean connectDB(String url, String username, String password) {
        try { this.connection = DriverManager.getConnection(url, username, password);
        } catch (SQLException se) { return false; }
        return true;
    }

    @Override
    public boolean disconnectDB() {
        try { connection.close(); }
        catch (SQLException se) { return false; }
        return true;
    }

    @Override
    public ElectionCabinetResult electionSequence(String countryName) {
        List<Integer> elections = new ArrayList<>();
        List<Integer> cabinets = new ArrayList<>();

        try {
            PreparedStatement electionStat = connection.prepareStatement(
                "SELECT id, e_type, e_date FROM election WHERE country_id=(SELECT id FROM country WHERE name=?) ORDER BY e_date");
            electionStat.setString(1, countryName);
            ResultSet electionSet = electionStat.executeQuery();

            while (electionSet.next()) {
                int electionID = electionSet.getInt("id");
                String electionType = electionSet.getString("e_type");
                java.sql.Date electionDate = electionSet.getDate("e_date");

                elections.add(0, electionID);

                // Find the date of the next election of the same type
                String nextType = electionType.equals("European Parliament") ? "previous_ep_election_id" : "previous_parliament_election_id";
                PreparedStatement nextElectionStat = connection.prepareStatement(
                    "SELECT e_date FROM election WHERE " + nextType + "=?");
                nextElectionStat.setInt(1, electionID);
                ResultSet nextElectionSet = nextElectionStat.executeQuery();

                PreparedStatement cabinetStat;
                if (nextElectionSet.next()) {
                    java.sql.Date nextElectionDate = nextElectionSet.getDate("e_date");
                    cabinetStat = connection.prepareStatement(
                        "SELECT id FROM cabinet WHERE start_date >= ? AND start_date < ? AND election_id=?");
                    cabinetStat.setDate(1, electionDate);
                    cabinetStat.setDate(2, nextElectionDate);
                    cabinetStat.setInt(3, electionID);
                } else {
                    // This is the most recent election of this type
                    cabinetStat = connection.prepareStatement(
                        "SELECT id FROM cabinet WHERE start_date >= ? AND election_id=?");
                    cabinetStat.setDate(1, electionDate);
                    cabinetStat.setInt(2, electionID);
                }

                // Add cabinets to cabinets list
                ResultSet cabinetSet = cabinetStat.executeQuery();
                while (cabinetSet.next())
                    cabinets.add(0, cabinetSet.getInt("id"));
            }
        } catch (SQLException se) { return null; }

        return new ElectionCabinetResult(elections, cabinets);
    }

    @Override
    public List<Integer> findSimilarPoliticians(Integer politicianId, Float threshold) {
        List<Integer> similarPoliticians = new ArrayList<>();

        try {
            PreparedStatement politicianStat = connection.prepareStatement(
                "SELECT description, comment FROM politician_president WHERE id=?");
            politicianStat.setInt(1, politicianId);
            ResultSet politicianSet = politicianStat.executeQuery();

            // First find the data of the politician to compare with
            String politicianDesc, politicianComment;
            if (politicianSet.next()) {
                politicianDesc = politicianSet.getString("description");
                politicianComment = politicianSet.getString("comment");
            } else return null;  // politicianId was not found

            // A politician is not similar to themself
            PreparedStatement similarStat = connection.prepareStatement(
                "SELECT id, description, comment FROM politician_president WHERE id<>?");
            similarStat.setInt(1, politicianId);
            ResultSet similarSet = similarStat.executeQuery();

            while (similarSet.next()) {
                String desc = similarSet.getString("description");
                String comment = similarSet.getString("comment");

                // Find similar politicians with inputted politician
                if (similarity(desc + comment, politicianDesc + politicianComment) >= threshold)
                    similarPoliticians.add(similarSet.getInt("id"));
            }

        } catch (SQLException se) { return null; }

        return similarPoliticians;
    }

    public static void main(String[] args) {
        try {
            Assignment2 test = new Assignment2();

            test.connectDB("jdbc:postgresql://localhost:5432/csc343h-choihy38?currentSchema=parlgov", "choihy38", "");
            // System.out.println(test.electionSequence("Japan").toString());
            // System.out.println(test.findSimilarPoliticians(37, .1f).toString());
            test.disconnectDB();
        } catch (ClassNotFoundException e) { return; }
    }

}

