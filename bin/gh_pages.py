import db_init, connection

from import_new_db import cur
import os, ast

ghpages_dir = "queries/gh-pages"

def parse_sql_metadata(file):
    title = description = summary = valrange = valfiles = headers = ""
    for line in file:
            if line.startswith("##"):
                line = line.replace("##","")
                if line.startswith("title"):
                    title = line.replace("title","").strip()
                elif line.startswith("desc"):
                    description = line.replace("desc","").strip()
                elif line.startswith("summary"):
                    summary = line.replace("summary","").strip()
                elif line.startswith("valrange"):
                    valrange = line.replace("valrange","").strip()
                    if valrange == 'Events':
                        valrange = ['333','222','444','555','666','777','333bf','333fm','333oh','clock','minx','pyram','skewb','sq1','444bf','555bf','333mbf']
                    else:
                        valrange = eval(line.replace("valrange","").strip())
                elif line.startswith("valfiles"):
                    valfiles = line.replace("valfiles","").strip()
                elif line.startswith("headers"):
                    headers = eval(line.replace("headers","").strip())
    return title, description, summary, valrange, valfiles, headers

def create_query_table(cur):
    rows = cur.fetchall()
    columns = [i[0] for i in cur.description]

    result = []
    
    for row in rows:
        row_dict = {}
        for i, column in enumerate(columns):
            row_dict[column] = row[i]
        result.append(row_dict)

    table = []
    last_rank = None

    for row in result:
        this_row = row.copy()
        for value in row:
            if value == "personId":
                if row[value] is None:
                    this_row["personURL"] = ""
                else:
                    this_row["personURL"] = "https://www.worldcubeassociation.org/persons/" + row[value]
            if value == "competitionId":
                if row[value] is None:
                    this_row["competitionURL"] = ""
                else:
                    this_row["competitionURL"] = "https://www.worldcubeassociation.org/competitions/" + row[value]
            elif value == "Rank":
                if last_rank != None:
                    if row[value] == last_rank:
                        this_row["Rank"] = "="
                last_rank = row[value]
        table.append(this_row)

    return table

def generate_html_table(table, headers):
    html_table = "<table>\n"
    html_table += "<tr>"
    for header in headers:
        html_table += "<th>{}</th>".format(header)
    html_table += "</tr>\n"

    for row in table:
        html_table += "<tr>"
        for header in headers:
            if header == "Person":
                html_table += "<td><a href='{}'>{}</a></td>".format(row["personURL"], row["personName"])
            elif header == "Competition" and row["competitionURL"] != '':
                html_table += "<td><a href='{}'>{}</a></td>".format(row["competitionURL"], row["competitionName"])
            else:
                value = row.get(header, "")
                if isinstance(value, bytes):
                    value = value.decode("utf-8")
                html_table += "<td>{}</td>".format(value)
        html_table += "</tr>\n"

    html_table += "</table>"

    return html_table

cur.execute("USE wca_stats")
for file in os.listdir(ghpages_dir):
    file_path = os.path.join(ghpages_dir, file)
    
    with open(file_path, "r") as f:
        title, description, summary, valrange, valfiles, headers = parse_sql_metadata(f)
        if valrange == '':
            pass
        else:
            for val in valrange:
                if '{X}' in title:
                    this_title = title.format(X=val)
                    print(this_title)
                    val_centi = val * 100
                    f.seek(0)
                    query = ''.join(line for line in f if not line.startswith("##")).format(X=val, best=val_centi)
                    #query = f.read().format(X=val, best=val_centi)
                    cur.execute(query)
                    table = create_query_table(cur)
                    html_table = generate_html_table(table, headers)
                    this_file = "docs/{}/{}.html".format(file.replace(".sql","",),valfiles.format(X=val))
                elif '{text}' in title:
                    this_title = title.format(text=val)
                    print(this_title)
                    f.seek(0)
                    query = ''.join(line for line in f if not line.startswith("##")).format(text=val)
                    cur.execute(query, multi=True)
                    if query.startswith('SET'):
                        cur.nextset()
                    table = create_query_table(cur)
                    html_table = generate_html_table(table, headers)
                    this_file = "docs/{}/{}.html".format(file.replace(".sql","",),valfiles.format(text=val))
                else:
                    this_title = title
                    print(this_title)
                    query = f.read()
                    cur.execute(query)
                    table = create_query_table(cur)
                    html_table = generate_html_table(table, headers)
                    this_file = "docs/{}/{}.html".format(file.replace(".sql","",),valfiles.format(tier=val))
                
                os.makedirs(os.path.dirname(this_file), exist_ok=True)

                with open("docs/template.html", "r") as f_template:
                    template = f_template.read()

                template = template.replace("<!-- title -->",this_title)
                template = template.replace("<!-- summary -->",summary)
                template = template.replace("<!-- description -->",description)
                template = template.replace("<!-- table -->",html_table)

                with open(this_file, "w+", encoding="utf-8") as f_out:
                    f_out.write(template)
                    