import re
import struct
length_pattern=r",[a-z+!]{1,3}"
meta_pattern=r""
offset=0
i=0
length_list=[]
with open(r"..\database_tsv\songlengths.tsv",'r',encoding='utf-8') as l_handle:
    with open(r"..\database\songlengths.bin",'wb') as outputc:
        outputc.write("UADESLDB".encode("ascii"))
        for line in l_handle:
            i+=1
        l_handle.seek(0)
        outputc.write(struct.pack('<I',i))
        outputc.write(struct.pack('<I', i * 16 + 16))
        for line in l_handle:
            _,_,lengths=line.split("\t")
            for element in re.sub(length_pattern, "", lengths).rstrip().split(" "):
                length_list.append(int(element))
        l_handle.seek(0)
        for line in l_handle:
            md5,subsong,lengths=line.split("\t")
            lengths = re.sub(length_pattern, "", lengths).rstrip().replace(" ", ",")
            counts=lengths.count(",")+1
            outputc.write(struct.pack('<QIHH',int(md5,16), offset, int(subsong),counts))
            offset += counts - 1
            offset+=1

        for item in length_list:
            outputc.write(struct.pack('<I',int(item)))

offset=0
i=0
with open(r"..\database_tsv\metadata.tsv",'r',encoding='utf-8') as m_handle:
        with open(r"..\database\metadata.bin",'wb') as outputc:
            outputc.write("UADEMADB".encode("ascii"))
            for line in m_handle:
                i += 1
            m_handle.seek(0)
            outputc.write(struct.pack('<I', i))
            outputc.write(struct.pack('<I', i * 14 + 16))
            for line in m_handle:
                md5,authors,publishers,album,year=line.split("\t")
                authors=authors.rstrip().replace("~",", ").replace("\"",r'\"') + "\0"
                publishers=publishers.rstrip().replace("~",", ").replace("\"",r'\"') + "\0"
                album=album.rstrip().replace("\"",r'\"') + "\0"
                year=year.rstrip() + "\0"
                str_length=len((authors+publishers+album+year).encode("utf-8"))
                outputc.write(struct.pack("<QIH",int(md5,16),offset,str_length))
                offset+=str_length
            m_handle.seek(0)
            for line in m_handle:
                md5, authors, publishers, album, year = line.split("\t")
                authors = authors.rstrip().replace("~", ", ").replace("\"", r'\"') + "\0"
                publishers = publishers.rstrip().replace("~", ", ").replace("\"", r'\"') + "\0"
                album = album.rstrip().replace("\"", r'\"') + "\0"
                year = year.rstrip() + "\0"
                outputc.write((authors+publishers+album+year).encode("utf-8"))

            