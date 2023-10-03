@extends('layouts.tempNav')
@section('container')
<div class="row">
    <div class="col-sm-6 .col-sm-8"><a href="#"><button type="button" class="btn btn-outline-warning"><i class="fa-solid fa-plus"></i> Tambah Masjid</button></a></div>
    <div class="col-6 .col-sm-4"><h3><i class="fa-solid fa-mosque"></i> Daftar Masjid</h3></div>
</div>
<hr>
<div class="container">
    <table class="table text-center">
        <thead>
            <th scope="col">No</th>
            <th scope="col">ID</th>
            <th scope="col">Nama Masjid</th>
            <th scope="col">Aksi</th>
        </thead>
        <tbody class="table-group-divider">
            <tr>
                <td>1</td>
                <td>2057051017</td>
                <td>Masjid A</td>
                <td>
                    <div class="btn-group btn-group-sm" role="group" aria-label="Small button group">
                        <a href="#"><button type="button" class="btn btn-outline-info"><i class="fa-solid fa-info"></i></button></a>
                        <a href="#"><button type="button" class="btn btn-outline-danger"><i class="fa-solid fa-trash"></i></button></a>
                    </div>
                </td>
            </tr>
        </tbody>
    </table> 
</div> 
@endsection